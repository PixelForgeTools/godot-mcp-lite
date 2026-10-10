#!/usr/bin/env python3
"""
Godot MCP Lite stdio bridge (stdlib only).
Forwards newline-delimited JSON-RPC from stdin/stdout to the Godot plugin at 127.0.0.1:6506.
Usage: python3 bridge.py   (set as MCP server command in LM Studio / Ollama hosts)
"""
import socket, sys, threading

HOST, PORT = "127.0.0.1", 6506

def pump_stdout(sock):
    buf = b""
    while True:
        data = sock.recv(65536)
        if not data:
            break
        buf += data
        while b"\n" in buf:
            line, buf = buf.split(b"\n", 1)
            if line.strip():
                sys.stdout.buffer.write(line + b"\n"); sys.stdout.buffer.flush()

def main():
    try:
        sock = socket.create_connection((HOST, PORT), timeout=5)
    except OSError as e:
        sys.stderr.write(f"bridge: cannot connect to Godot MCP Lite on {HOST}:{PORT} ({e}). Open Godot and enable the plugin first.\n")
        sys.exit(1)
    t = threading.Thread(target=pump_stdout, args=(sock,), daemon=True); t.start()
    for raw in sys.stdin.buffer:
        if raw.strip():
            sock.sendall(raw if raw.endswith(b"\n") else raw + b"\n")

if __name__ == "__main__":
    main()
