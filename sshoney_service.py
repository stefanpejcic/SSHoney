import socket
import threading
from spawn_session import spawn_session

LISTEN_PORT = 2222

def handle_connection(conn, addr):
    attacker_ip = addr[0]
    print(f"[+] Incoming connection from {attacker_ip}")
    spawn_session(attacker_ip)
    conn.close()

def start_listener():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind(('', LISTEN_PORT))
    server_socket.listen()
    print(f"[+] SSHoney service listening on port {LISTEN_PORT}")

    while True:
        conn, addr = server_socket.accept()
        threading.Thread(target=handle_connection, args=(conn, addr)).start()

if __name__ == "__main__":
    start_listener()
  
