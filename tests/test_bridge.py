import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "agents"))
from bridge import Bridge, AGENTS


class FakeResponse:
    status = 200
    def __enter__(self):
        return self
    def __exit__(self, exc_type, exc, tb):
        return False
    def read(self, n):
        return json.dumps({"reply": "Dostałem wiadomość"}).encode("utf-8")


class BridgeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.db = Path(self.temp.name) / "messages.sqlite3"

    def tearDown(self):
        self.temp.cleanup()

    def make_bridge(self, **kwargs):
        return Bridge(db_path=self.db, gateway_url="", send_path="", token="", **kwargs)

    def test_four_identities_and_no_fake_online(self):
        b = self.make_bridge()
        self.assertEqual(tuple(b.status()["agents"]), AGENTS)
        self.assertEqual(b.status()["gateway_online"], "not_checked")

    def test_local_message_queue(self):
        b = self.make_bridge()
        result = b.send("user", "Alex", "Test")
        self.assertEqual(result[0]["state"], "queued")
        self.assertEqual(b.inbox("alex")[0]["text"], "Test")

    def test_all_broadcast(self):
        b = self.make_bridge()
        result = b.send("user", "all", "Witajcie")
        self.assertEqual(len(result), 4)
        self.assertEqual({msg["recipient"] for msg in result}, set(AGENTS))

    def test_agent_to_agent_and_user(self):
        b = self.make_bridge()
        b.send("Aria", "Aurelius", "Cześć")
        b.send("Aurelius", "user", "Odpowiedź")
        self.assertEqual(b.inbox("Aurelius")[0]["sender"], "Aria")
        self.assertEqual(b.inbox("user")[0]["state"], "inbox")

    def test_invalid_identity(self):
        b = self.make_bridge()
        with self.assertRaises(ValueError):
            b.send("user", "unknown", "test")

    def test_no_plain_http_to_remote(self):
        with self.assertRaises(ValueError):
            Bridge(db_path=self.db, gateway_url="http://remote.example", send_path="/send", token="secret")

    def test_remote_success_and_real_reply(self):
        b = Bridge(db_path=self.db, gateway_url="https://agents.example",
                   send_path="/send", token="dummy-for-tests")
        with patch("bridge.urlopen", return_value=FakeResponse()) as mock:
            sent = b.send("user", "Alex", "Ping")
        self.assertEqual(sent[0]["state"], "accepted")
        self.assertEqual(b.inbox("user")[0]["sender"], "Alex")
        request = mock.call_args.args[0]
        self.assertEqual(json.loads(request.data)["agent"], "Alex")
        self.assertEqual(request.get_header("Authorization"), "Bearer dummy-for-tests")


if __name__ == "__main__":
    unittest.main()
