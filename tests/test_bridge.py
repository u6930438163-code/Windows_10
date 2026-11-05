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


    def test_conversation_isolated_by_agent(self):
        b = self.make_bridge()
        b.send("user", "Alex", "Pytanie do Alexa")
        b.send("user", "Aria", "Pytanie do Arii")
        b.send("Alex", "user", "Odpowiedź Alexa")
        only_alex = b.conversation("Alex")
        self.assertEqual([row["text"] for row in only_alex],
                         ["Pytanie do Alexa", "Odpowiedź Alexa"])
        only_aria = b.conversation("Aria")
        self.assertEqual([row["text"] for row in only_aria], ["Pytanie do Arii"])

    def test_everyone_channel_includes_agent_to_agent(self):
        b = self.make_bridge()
        b.send("Astyria", "Aurelius", "Współpraca")
        b.send("user", "all", "Wspólny komunikat")
        rows = b.conversation("all")
        self.assertEqual(len(rows), 5)
        self.assertEqual(rows[0]["sender"], "Astyria")
        self.assertEqual([m["id"] for m in rows], sorted(m["id"] for m in rows))

    def test_conversation_limits_and_invalid_agent(self):
        b = self.make_bridge()
        for index in range(4):
            b.send("user", "Aria", "Wiadomość " + str(index))
        messages = b.conversation("Aria", limit=2)
        self.assertEqual([m["text"] for m in messages],
                         ["Wiadomość 2", "Wiadomość 3"])
        with self.assertRaises(ValueError):
            b.conversation("fake")

    def test_deferred_delivery_is_not_reported_as_accepted(self):
        b = Bridge(db_path=self.db, gateway_url="https://agents.example",
                   send_path="/send", token="dummy-for-tests")
        with patch("bridge.urlopen") as mock:
            result = b.send("user", "Alex", "Do kolejki", deliver=False)
        self.assertEqual(result[0]["state"], "queued")
        mock.assert_not_called()



if __name__ == "__main__":
    unittest.main()
