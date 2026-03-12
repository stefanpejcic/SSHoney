# File: spawn_session.py
import subprocess
import time
import os
import sys

SESSION_LOGS_DIR = os.path.abspath("./session-logs")

def spawn_session(attacker_ip):
    timestamp = int(time.time())
    log_file_host = os.path.join(SESSION_LOGS_DIR, f"session_{timestamp}.log")

    # Ensure the log file exists
    open(log_file_host, 'a').close()

    # Run ephemeral container with single log file mounted
    cmd = [
        "docker", "run", "--rm",
        "--name", f"honeypot_{timestamp}",
        "-v", f"{log_file_host}:/var/log/session.log",
        "-p", "0:22",  # Random host port
        "ssh-honeypot-image"
    ]

    print(f"[+] Spawning ephemeral honeypot container for IP {attacker_ip}")
    subprocess.run(cmd)
    print(f"[+] Container terminated. Session log saved at {log_file_host}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python spawn_session.py <attacker_ip>")
        sys.exit(1)
    attacker_ip = sys.argv[1]
    spawn_session(attacker_ip)
