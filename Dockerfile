# File: Dockerfile
FROM ubuntu:24.04

# Install SSH server
RUN apt-get update && \
    apt-get install -y openssh-server bash && \
    mkdir /var/run/sshd /var/log

# Allow root login
RUN echo 'root:password' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Add script to randomize SSH banner
RUN echo '#!/bin/bash' > /usr/local/bin/start_sshd.sh && \
    echo 'BANNERS=("SSH-2.0-OpenSSH_7.4p1" "SSH-2.0-OpenSSH_8.0" "SSH-2.0-dropbear_2018.76")' >> /usr/local/bin/start_sshd.sh && \
    echo 'RANDOM_BANNER=${BANNERS[$RANDOM % ${#BANNERS[@]}]}' >> /usr/local/bin/start_sshd.sh && \
    echo 'echo "Using banner: $RANDOM_BANNER"' >> /usr/local/bin/start_sshd.sh && \
    echo 'exec /usr/sbin/sshd -D -e -o "VersionAddendum=$RANDOM_BANNER"' >> /usr/local/bin/start_sshd.sh && \
    chmod +x /usr/local/bin/start_sshd.sh

# Force logging of session commands to mounted file
RUN echo 'export PROMPT_COMMAND="script -q -f /var/log/session.log"' >> /root/.bashrc

EXPOSE 22

# Use the start script to run SSH server with randomized banner
CMD ["/usr/local/bin/start_sshd.sh"]
