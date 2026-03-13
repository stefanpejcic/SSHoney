# SSHoney 🍯

**SSHoney** is an **ephemeral, containerized SSH honeypot** designed to trap brute-force bots. Each attacker gets a **dedicated container session**, that auto-terminates when they disconnect.

---
[![Test SSHoney Installation and Session](https://github.com/stefanpejcic/SSHoney/actions/workflows/test-sshoney.yml/badge.svg)](https://github.com/stefanpejcic/SSHoney/actions/workflows/test-sshoney.yml)
---

## How it works

- service is running
- ssh connection is established, starts a container
- commands are logged
- disconnect = terminate containet

---


## Build

```bash
docker build -t ssh-honey-image .
```

---

## Usage



```

```

