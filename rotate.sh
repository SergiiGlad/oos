#!/bin/bash

# a temporary directory for cert generation /opt/k3s/server/tls

ssh vboxuser@192.168.0.166 -- 'echo changeme | sudo -S mkdir -p /opt/k3s/server/tls'
ssh vboxuser@192.168.0.166 -- 'echo changeme | sudo -S chmod -R 777 /opt/k3s/server/tls'
ssh vboxuser@192.168.0.166 -- 'echo changeme | sudo -S chmod -R 777 /var/lib/rancher'
# Use existing C
ssh vboxuser@192.168.0.166 -- 'echo changeme | sudo -S cp /var/lib/rancher/k3s/server/tls/root-ca.* /var/lib/rancher/k3s/server/tls/intermediate-ca.* /opt/k3s/server/tls'
# Copy the current service-account signing key, so that existing service-account tokens are not invalidated.
ssh vboxuser@192.168.0.166 -- 'echo changeme | sudo -S cp /var/lib/rancher/k3s/server/tls/service.key /opt/k3s/server/tls'
# Generating custom certs
ssh vboxuser@192.168.0.166 -- 'echo changeme | sudo -S DATA_DIR=/opt/k3s bash -c /home/vboxuser/k3s/contrib/util/generate-custom-ca-certs-origin.sh'
ssh vboxuser@192.168.0.166 -- 'echo changeme | sudo -S chmod -R 777 /opt/k3s/server/tls'
# Change server and client CA
ssh vboxuser@192.168.0.166 -- 'tee /opt/k3s/server/tls/server-ca.key <<< "${SERVER_KEY}"'
ssh vboxuser@192.168.0.166 -- 'tee /opt/k3s/server/tls/server-ca.pem <<< "${SERVER_PEM}"'
ssh vboxuser@192.168.0.166 -- 'tee /opt/k3s/server/tls/client-ca.key <<< "${CLIENT_KEY}"'
ssh vboxuser@192.168.0.166 -- 'tee /opt/k3s/server/tls/client-ca.pem <<< "${CLIENT_PEM}"'
# Create server and client crt
ssh vboxuser@192.168.0.166 -- 'cd /opt/k3s/server/tls; cat server-ca.pem intermediate-ca.pem root-ca.pem > server-ca.crt'
ssh vboxuser@192.168.0.166 -- 'cd /opt/k3s/server/tls; cat client-ca.pem intermediate-ca.pem root-ca.pem > client-ca.crt'
# Load the updated CA certs and keys into the datastore.
ssh vboxuser@192.168.0.166 -- 'echo changeme | sudo -S k3s certificate rotate-ca --path=/opt/k3s/server --force'
ssh vboxuser@192.168.0.166 -- 'echo changeme | sudo -S systemctl stop k3s.service'
ssh vboxuser@192.168.0.166 -- 'echo changeme | sudo -S systemctl start k3s.service'
