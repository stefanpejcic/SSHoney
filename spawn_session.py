import subprocess
import os
import time

SESSION_LOGS_DIR = os.path.abspath("./session-logs")
CONTAINER_TIMEOUT = 3600  # 1 hour

def spawn_session(attacker_ip):
    container_name = f"honeypot_{attacker_ip.replace('.', '_')}"
    log_file_host = os.path.join(SESSION_LOGS_DIR, f"session_{attacker_ip}.log")
    
    # Ensure log file exists
    os.makedirs(os.path.dirname(log_file_host), exist_ok=True)
    open(log_file_host, 'a').close()

    # Check if container already exists
    result = subprocess.run(["docker", "ps", "-q", "-f", f"name={container_name}"], capture_output=True, text=True)
    if result.stdout.strip():
        print(f"[+] Existing container found for {attacker_ip}, reusing log file.")
        return

    # Run ephemeral container in background
    cmd = [
        "docker", "run", "--rm",
        "--name", container_name,
        "-v", f"{log_file_host}:/var/log/session.log",
        "-p", "0:22",
        "ssh-honeypot-image"
    ]
    print(f"[+] Spawning new container for {attacker_ip}")
    subprocess.Popen(cmd)

    # Schedule auto-cleanup after 1 hour
    def cleanup():
        time.sleep(CONTAINER_TIMEOUT)
        subprocess.run(["docker", "rm", "-f", container_name])
        print(f"[+] Container {container_name} auto-terminated after 1 hour")

    import threading
    threading.Thread(target=cleanup, daemon=True).start()
    
