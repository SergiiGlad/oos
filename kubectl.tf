provider "kubectl" {
  host = "https://192.168.0.166:6443"
  cluster_ca_certificate = format("%s%s%s",
    tls_locally_signed_cert.server.cert_pem,
    tls_locally_signed_cert.intermediate.cert_pem,
    tls_self_signed_cert.root_ca.cert_pem
  )
  client_certificate = format("%s%s%s%s",
    tls_locally_signed_cert.admin.cert_pem,
    tls_locally_signed_cert.client.cert_pem,
    tls_locally_signed_cert.intermediate.cert_pem,
    tls_self_signed_cert.root_ca.cert_pem
  )
  client_key       = tls_private_key.admin.private_key_pem
  load_config_file = false
}

resource "kubectl_manifest" "test" {
  yaml_body  = <<-YAML
kind: Namespace
apiVersion: v1
metadata:
  name: test
  labels:
    name: test
YAML
  depends_on = [null_resource.k3s]
}