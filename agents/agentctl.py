"""CLI i lokalny serwer HTTP komunikacji agentów Windows_10."""
import argparse
import hmac
import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlsplit

from bridge import Bridge


def serve(bridge, port):
    token = os.environ.get("WINDOWS10_LOCAL_TOKEN", "")
    if len(token) < 16:
        raise SystemExit("Ustaw WINDOWS10_LOCAL_TOKEN (min. 16 znaków) przed uruchomieniem serwera.")

    class Handler(BaseHTTPRequestHandler):
        def log_message(self, fmt, *args):
            return

        def reply(self, status, data):
            blob = json.dumps(data, ensure_ascii=False).encode("utf-8")
            self.send_response(status)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(blob)))
            self.send_header("Cache-Control", "no-store")
            self.end_headers()
            self.wfile.write(blob)

        def authorized(self):
            provided = self.headers.get("Authorization", "")
            if not hmac.compare_digest(provided, "Bearer " + token):
                self.reply(401, {"error": "unauthorized"})
                return False
            return True

        def do_GET(self):
            if not self.authorized():
                return
            parsed = urlsplit(self.path)
            try:
                if parsed.path == "/v1/agents":
                    self.reply(200, bridge.status())
                elif parsed.path == "/v1/inbox":
                    args = parse_qs(parsed.query)
                    recipient = args.get("recipient", ["user"])[0]
                    since = int(args.get("since", ["0"])[0])
                    self.reply(200, {"messages": bridge.inbox(recipient, since)})
                elif parsed.path == "/v1/conversation":
                    args = parse_qs(parsed.query)
                    agent = args.get("agent", ["all"])[0]
                    since = int(args.get("since", ["0"])[0])
                    limit = int(args.get("limit", ["100"])[0])
                    self.reply(200, {"messages": bridge.conversation(agent, since, limit)})
                else:
                    self.reply(404, {"error": "not found"})
            except (ValueError, TypeError) as exc:
                self.reply(400, {"error": str(exc)})

        def do_POST(self):
            if not self.authorized():
                return
            if urlsplit(self.path).path != "/v1/messages":
                self.reply(404, {"error": "not found"})
                return
            try:
                size = int(self.headers.get("Content-Length", "0"))
                if size <= 0 or size > 8192:
                    self.reply(413, {"error": "invalid body size"})
                    return
                body = json.loads(self.rfile.read(size).decode("utf-8"))
                self.reply(200, {"messages": bridge.send(body["sender"], body["recipient"], body["message"])})
            except (KeyError, ValueError, TypeError, UnicodeError) as exc:
                self.reply(400, {"error": str(exc)})

    print("Serwer lokalny: http://127.0.0.1:" + str(port))
    with ThreadingHTTPServer(("127.0.0.1", port), Handler) as httpd:
        httpd.serve_forever()


def main():
    p = argparse.ArgumentParser(description="Windows_10: komunikacja czterech agentów")
    sub = p.add_subparsers(dest="cmd", required=True)
    sub.add_parser("status")
    send = sub.add_parser("send")
    send.add_argument("--from", dest="sender", required=True)
    send.add_argument("--to", dest="recipient", required=True)
    send.add_argument("--text", required=True)
    inbox = sub.add_parser("inbox")
    inbox.add_argument("--agent", required=True)
    inbox.add_argument("--since", type=int, default=0)
    conversation = sub.add_parser("conversation")
    conversation.add_argument("--agent", required=True)
    conversation.add_argument("--since", type=int, default=0)
    conversation.add_argument("--limit", type=int, default=100)
    retry = sub.add_parser("retry")
    retry.add_argument("--id", type=int, required=True)
    server = sub.add_parser("serve")
    server.add_argument("--port", type=int, default=8765)
    args = p.parse_args()
    bridge = Bridge()
    if args.cmd == "serve":
        serve(bridge, args.port)
        return
    result = {
        "status": bridge.status,
        "send": lambda: bridge.send(args.sender, args.recipient, args.text),
        "inbox": lambda: bridge.inbox(args.agent, args.since),
        "conversation": lambda: bridge.conversation(args.agent, args.since, args.limit),
        "retry": lambda: bridge.retry(args.id),
    }[args.cmd]()
    print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
