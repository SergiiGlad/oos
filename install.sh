#!/bin/bash

# Clone k3s
# ssh vboxuser@192.168.0.166 -- 'echo changeme | sudo -S git clone https://github.com/k3s-io/k3s.git'
# Create folder for certs
ssh vboxuser@192.168.0.166 -- 'echo changeme | sudo -S mkdir -p /var/lib/rancher/k3s/server/tls'
ssh vboxuser@192.168.0.166 -- 'echo changeme | sudo -S chmod -R 777 /var/lib/rancher/k3s/server'
# Use existing CA
ssh vboxuser@192.168.0.166 -- 'tee /var/lib/rancher/k3s/server/tls/root-ca.pem <<< "${ROOT_CA_PEM_CERT}"'
ssh vboxuser@192.168.0.166 -- 'tee /var/lib/rancher/k3s/server/tls/root-ca.key <<< "${ROOT_CA_PRIVATE_KEY}"'
ssh vboxuser@192.168.0.166 -- 'tee /var/lib/rancher/k3s/server/tls/intermediate-ca.pem <<< "${INTERMEDIATE_CA_PEM}"'
ssh vboxuser@192.168.0.166 -- 'tee /var/lib/rancher/k3s/server/tls/intermediate-ca.key <<< "${INTERMEDIATE_CA_KEY}"'
# Generating custom certs
ssh vboxuser@192.168.0.166 -- 'echo changeme | sudo -S /home/vboxuser/k3s/contrib/util/generate-custom-ca-certs.sh'
# Change server and client CA
ssh vboxuser@192.168.0.166 -- 'tee /var/lib/rancher/k3s/server/tls/server-ca.key <<< "${SERVER_KEY}"'
ssh vboxuser@192.168.0.166 -- 'tee /var/lib/rancher/k3s/server/tls/server-ca.pem <<< "${SERVER_PEM}"'
ssh vboxuser@192.168.0.166 -- 'tee /var/lib/rancher/k3s/server/tls/client-ca.key <<< "${CLIENT_KEY}"'
ssh vboxuser@192.168.0.166 -- 'tee /var/lib/rancher/k3s/server/tls/client-ca.pem <<< "${CLIENT_PEM}"'
# Create server and client crt
ssh vboxuser@192.168.0.166 -- 'cd /var/lib/rancher/k3s/server/tls; cat server-ca.pem intermediate-ca.pem root-ca.pem > server-ca.crt'
ssh vboxuser@192.168.0.166 -- 'cd /var/lib/rancher/k3s/server/tls; cat client-ca.pem intermediate-ca.pem root-ca.pem > client-ca.crt'
#ssh vboxuser@192.168.0.166 -- 'curl -sL https://github.com/k3s-io/k3s/raw/master/contrib/util/generate-custom-ca-certs.sh | bash -'
# Install k3s
ssh vboxuser@192.168.0.166 -- 'echo changeme | sudo -S ./k3s.sh; wait'
# Check k3s running
while true; do
    if [ "$(ssh vboxuser@192.168.0.166 -- 'systemctl -l|grep k3s.service|grep running')" != "" ]; then
        break
    fi
    sleep 5
done
ssh vboxuser@192.168.0.166 -- 'systemctl status k3s.service'
