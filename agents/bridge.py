"""Windows_10: lokalna szyna wiadomości czterech istniejących agentów.

Nie udaje uruchomionych modeli. Dostarczenie do zewnętrznego backendu wymaga
jawnego ustawienia AGENT_GATEWAY_URL, AGENT_GATEWAY_SEND_PATH i tokenu.
"""
import json
import os
import sqlite3
from contextlib import closing
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urljoin, urlsplit
from urllib.request import Request, urlopen

AGENTS = ("Alex", "Aria", "Astyria", "Aurelius")
PARTICIPANTS = (*AGENTS, "user")
LOOPBACK = {"127.0.0.1", "localhost", "::1"}


def normalize(name, allow_all=False):
    if not isinstance(name, str):
        raise ValueError("Nazwa uczestnika musi być tekstem.")
    if allow_all and name.casefold() == "all":
        return "all"
    for value in PARTICIPANTS:
        if value.casefold() == name.casefold():
            return value
    raise ValueError("Nieznany uczestnik: " + name)


class Bridge:
    def __init__(self, db_path=None, gateway_url=None, send_path=None, token=None):
        default_db = Path(__file__).resolve().parent / "messages.sqlite3"
        self.db_path = Path(db_path or os.environ.get("WINDOWS10_AGENT_DB") or default_db)
        self.gateway_url = gateway_url if gateway_url is not None else os.environ.get("AGENT_GATEWAY_URL", "")
        self.send_path = send_path if send_path is not None else os.environ.get("AGENT_GATEWAY_SEND_PATH", "")
        self.token = token if token is not None else os.environ.get("AGENT_GATEWAY_TOKEN", "")
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        if self.gateway_url:
            url = urlsplit(self.gateway_url)
            if not url.hostname or url.username or url.password:
                raise ValueError("Nieprawidłowy AGENT_GATEWAY_URL.")
            if url.scheme != "https" and not (url.scheme == "http" and url.hostname in LOOPBACK):
                raise ValueError("Zewnętrzna brama musi używać HTTPS (HTTP dozwolone tylko lokalnie).")
            if url.hostname not in LOOPBACK and not self.token:
                raise ValueError("Dla zewnętrznej bramy wymagany jest AGENT_GATEWAY_TOKEN.")
            if self.send_path and (not self.send_path.startswith("/") or self.send_path.startswith("//")):
                raise ValueError("AGENT_GATEWAY_SEND_PATH musi być ścieżką zaczynającą się od /.")
        with closing(sqlite3.connect(self.db_path)) as conn:
            conn.execute("""CREATE TABLE IF NOT EXISTS messages (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                created_at TEXT NOT NULL,
                sender TEXT NOT NULL,
                recipient TEXT NOT NULL,
                text TEXT NOT NULL,
                state TEXT NOT NULL,
                error TEXT DEFAULT ''
            )""")
            conn.commit()

    def _save(self, sender, recipient, text, state):
        with closing(sqlite3.connect(self.db_path)) as conn:
            cursor = conn.execute(
                "INSERT INTO messages (created_at,sender,recipient,text,state) VALUES (?,?,?,?,?)",
                (datetime.now(timezone.utc).isoformat(), sender, recipient, text, state),
            )
            conn.commit()
            return cursor.lastrowid

    def _state(self, message_id, state, error=""):
        with closing(sqlite3.connect(self.db_path)) as conn:
            conn.execute("UPDATE messages SET state=?,error=? WHERE id=?", (state, error[:400], message_id))
            conn.commit()

    def _record(self, row):
        return dict(zip(("id","created_at","sender","recipient","text","state","error"), row))

    def get(self, message_id):
        with closing(sqlite3.connect(self.db_path)) as conn:
            row = conn.execute(
                "SELECT id,created_at,sender,recipient,text,state,error FROM messages WHERE id=?",
                (message_id,),
            ).fetchone()
        return self._record(row) if row else None

    def inbox(self, recipient, since=0, limit=50):
        recipient = normalize(recipient)
        since = max(int(since), 0)
        limit = max(1, min(int(limit), 100))
        with closing(sqlite3.connect(self.db_path)) as conn:
            rows = conn.execute(
                "SELECT id,created_at,sender,recipient,text,state,error FROM messages "
                "WHERE recipient=? AND id>? ORDER BY id LIMIT ?",
                (recipient, since, limit),
            ).fetchall()
        return [self._record(row) for row in rows]

    def conversation(self, agent, since=0, limit=100):
        """Historia rozmowy użytkownika z agentem lub zbiorczy kanał 'all'."""
        agent = normalize(agent, allow_all=True)
        since = max(int(since), 0)
        limit = max(1, min(int(limit), 200))
        with closing(sqlite3.connect(self.db_path)) as conn:
            if agent == "all":
                rows = conn.execute(
                    "SELECT id,created_at,sender,recipient,text,state,error FROM messages "
                    "WHERE id>? ORDER BY id DESC LIMIT ?",
                    (since, limit),
                ).fetchall()
            else:
                rows = conn.execute(
                    "SELECT id,created_at,sender,recipient,text,state,error FROM messages "
                    "WHERE ((sender='user' AND recipient=?) "
                    "OR (sender=? AND recipient='user')) AND id>? "
                    "ORDER BY id DESC LIMIT ?",
                    (agent, agent, since, limit),
                ).fetchall()
        return [self._record(row) for row in reversed(rows)]

    def status(self):
        return {
            "agents": list(AGENTS),
            "local_bus": "ready",
            "gateway_configured": bool(self.gateway_url and self.send_path),
            "gateway_online": "not_checked",
            "note": "Tożsamości istnieją; aktywność modeli i workerów nie jest potwierdzona.",
        }

    def send(self, sender, recipient, text):
        sender = normalize(sender)
        recipient = normalize(recipient, allow_all=True)
        if not isinstance(text, str) or not text.strip() or len(text) > 4000:
            raise ValueError("Treść musi zawierać 1–4000 znaków.")
        if recipient == "all":
            recipients = [agent for agent in AGENTS if agent != sender]
        else:
            recipients = [recipient]
        result = []
        for target in recipients:
            msg_id = self._save(sender, target, text, "inbox" if target == "user" else "queued")
            if target != "user" and self.gateway_url and self.send_path:
                self._deliver(msg_id)
            result.append(self.get(msg_id))
        return result

    def _deliver(self, message_id):
        msg = self.get(message_id)
        if not msg or msg["recipient"] == "user":
            return
        url = urljoin(self.gateway_url.rstrip("/") + "/", self.send_path.lstrip("/"))
        payload = json.dumps({
            "message_id": msg["id"], "agent": msg["recipient"],
            "sender": msg["sender"], "message": msg["text"],
        }).encode("utf-8")
        headers = {"Content-Type": "application/json", "Accept": "application/json"}
        if self.token:
            headers["Authorization"] = "Bearer " + self.token
        request = Request(url, data=payload, headers=headers, method="POST")
        try:
            with urlopen(request, timeout=10) as response:
                raw = response.read(16384)
                if not (200 <= response.status < 300):
                    raise RuntimeError("HTTP " + str(response.status))
            self._state(message_id, "accepted")
            if raw:
                try:
                    answer = json.loads(raw.decode("utf-8"))
                except (ValueError, UnicodeError):
                    answer = {}
                reply = answer.get("reply") if isinstance(answer, dict) else None
                if isinstance(reply, str) and reply.strip():
                    self._save(msg["recipient"], msg["sender"], reply[:4000], "inbox")
        except Exception as exc:
            # Never put token/URL into message error logs.
            self._state(message_id, "failed", type(exc).__name__)

    def retry(self, message_id):
        if not (self.gateway_url and self.send_path):
            raise RuntimeError("Brama nie jest skonfigurowana.")
        msg = self.get(int(message_id))
        if not msg or msg["state"] not in ("queued", "failed"):
            raise ValueError("Wiadomość nie istnieje lub została już przekazana.")
        self._deliver(msg["id"])
        return self.get(msg["id"])
