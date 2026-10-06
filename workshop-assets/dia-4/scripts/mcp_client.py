#!/usr/bin/env python3
"""Cliente MCP mínimo (Streamable HTTP, JSON-RPC 2.0) para los escenarios de la demo.

Uso:
  mcp_client.py <url> <apikey> list
  mcp_client.py <url> <apikey> call <tool> '<json-args>'

Salida (stdout, una línea JSON): {"http": <status>, "tools": [...]} o {"http": <status>, "result": {...}}
Sin dependencias externas (stdlib).
"""
import json
import sys
import urllib.error
import urllib.request

PROTOCOL = "2025-06-18"


def post(url, key, payload, session=None):
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json, text/event-stream",
        "MCP-Protocol-Version": PROTOCOL,
    }
    if key:
        headers["apikey"] = key
    if session:
        headers["Mcp-Session-Id"] = session
    req = urllib.request.Request(url, data=json.dumps(payload).encode(), headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return r.status, dict(r.headers), r.read().decode()
    except urllib.error.HTTPError as e:
        return e.code, dict(e.headers), e.read().decode()


def parse(body):
    """Acepta respuesta JSON o SSE (líneas 'data: {...}')."""
    body = body.strip()
    if not body:
        return None
    if body.startswith("{"):
        return json.loads(body)
    for line in body.splitlines():
        if line.startswith("data:"):
            data = line[5:].strip()
            if data.startswith("{"):
                return json.loads(data)
    return {"raw": body[:500]}


def main():
    url, key, op = sys.argv[1], sys.argv[2], sys.argv[3]
    status, headers, body = post(url, key, {
        "jsonrpc": "2.0", "id": 1, "method": "initialize",
        "params": {"protocolVersion": PROTOCOL, "capabilities": {},
                   "clientInfo": {"name": "aigw-demo-client", "version": "1.0"}},
    })
    if status != 200:
        print(json.dumps({"http": status, "error": (parse(body) or {})}))
        return
    session = {k.lower(): v for k, v in headers.items()}.get("mcp-session-id")
    post(url, key, {"jsonrpc": "2.0", "method": "notifications/initialized"}, session)

    if op == "list":
        status, _, body = post(url, key, {"jsonrpc": "2.0", "id": 2, "method": "tools/list"}, session)
        msg = parse(body) or {}
        tools = [t.get("name") for t in (msg.get("result") or {}).get("tools", [])]
        print(json.dumps({"http": status, "tools": tools, "error": msg.get("error")}))
    else:
        tool, args = sys.argv[4], json.loads(sys.argv[5] if len(sys.argv) > 5 else "{}")
        status, _, body = post(url, key, {"jsonrpc": "2.0", "id": 3, "method": "tools/call",
                                          "params": {"name": tool, "arguments": args}}, session)
        msg = parse(body) or {}
        print(json.dumps({"http": status, "result": msg.get("result"), "error": msg.get("error")}, ensure_ascii=False))


if __name__ == "__main__":
    main()
