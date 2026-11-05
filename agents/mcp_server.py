"""MCP stdio adapter do lokalnej szyny wiadomości.

Uruchom: python -m mcp run agents/mcp_server.py --transport stdio
Wymaga: pip install "mcp>=2,<3" (Python 3.11+).
"""
from mcp.server import MCPServer
from bridge import Bridge

mcp = MCPServer("Windows_10 Agents")


@mcp.tool()
def list_agents() -> dict:
    """Zwraca zarejestrowanych agentów; nie udaje statusu online."""
    return Bridge().status()


@mcp.tool()
def send_agent_message(sender: str, recipient: str, message: str) -> list[dict]:
    """Wyślij wiadomość do Alex/Aria/Astyria/Aurelius/user/all."""
    return Bridge().send(sender, recipient, message)


@mcp.tool()
def read_agent_inbox(agent: str, since: int = 0) -> list[dict]:
    """Odczytaj wiadomości konkretnego uczestnika (wymagana zgoda właściciela hosta)."""
    return Bridge().inbox(agent, since)
