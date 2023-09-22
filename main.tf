resource "tls_private_key" "root_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_private_key" "intermediate_ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_private_key" "server" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_private_key" "client" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_private_key" "admin" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

###########
# Requests
###########

resource "tls_cert_request" "intermediate_ca" {
  private_key_pem = tls_private_key.intermediate_ca.private_key_pem

  subject {
    country             = "UA"
    province            = "Kyiv"
    locality            = "Kyiv"
    organization        = "Software Solutions"
    organizational_unit = "Certification Auhtority"
  }
}

resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.server.private_key_pem

  subject {
    common_name         = "k3s-server-ca"
    country             = "UA"
    province            = "Kyiv"
    locality            = "Kyiv"
    organization        = "Software Solutions"
    organizational_unit = "Certification Auhtority"
  }
}

resource "tls_cert_request" "client" {
  private_key_pem = tls_private_key.client.private_key_pem

  subject {
    common_name         = "k3s-client-ca"
    country             = "UA"
    province            = "Kyiv"
    locality            = "Kyiv"
    organization        = "Software Solutions"
    organizational_unit = "Certification Auhtority"
  }
}

resource "tls_cert_request" "admin" {
  private_key_pem = tls_private_key.admin.private_key_pem

  subject {
    common_name         = "system:admin"
    country             = "UA"
    province            = "Kyiv"
    locality            = "Kyiv"
    organization        = "system:masters"
    organizational_unit = "Certification Auhtority"
  }
}

######
# PEMs
######

resource "tls_locally_signed_cert" "intermediate_ca" {
  cert_request_pem   = tls_cert_request.intermediate_ca.cert_request_pem
  ca_private_key_pem = tls_private_key.root_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.cm_ca_cert.cert_pem

  validity_period_hours = 43800 //  1825 days or 5 years

  is_ca_certificate = true

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "key_encipherment",
    "cert_signing",
  ]
}

resource "tls_locally_signed_cert" "server" {
  cert_request_pem   = tls_cert_request.server.cert_request_pem
  ca_private_key_pem = tls_private_key.intermediate_ca.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.intermediate_ca.cert_pem

  validity_period_hours = 43800 //  1825 days or 5 years

  is_ca_certificate = true

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "key_encipherment",
    "cert_signing",
  ]
}

resource "tls_locally_signed_cert" "client" {
  cert_request_pem   = tls_cert_request.client.cert_request_pem
  ca_private_key_pem = tls_private_key.intermediate_ca.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.intermediate_ca.cert_pem

  validity_period_hours = 43800 //  1825 days or 5 years

  is_ca_certificate = true

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "key_encipherment",
    "cert_signing",
  ]
}

resource "tls_locally_signed_cert" "admin" {
  cert_request_pem   = tls_cert_request.admin.cert_request_pem
  ca_private_key_pem = tls_private_key.client.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.client.cert_pem

  validity_period_hours = 43800 //  1825 days or 5 years

  is_ca_certificate = true

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "key_encipherment",
    "cert_signing",
  ]
}

###########
# Root PEM
###########

resource "tls_self_signed_cert" "cm_ca_cert" {
  private_key_pem = tls_private_key.root_key.private_key_pem

  is_ca_certificate = true
  ip_addresses = ["192.168.0.166"]

  subject {
    common_name         = "CA root"
    country             = "UA"
    province            = "Kyiv"
    locality            = "Kyiv"
    organization        = "Software Solutions"
    organizational_unit = "Certification Auhtority"
  }

  validity_period_hours = 43800 //  1825 days or 5 years

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "key_encipherment",
    "cert_signing",
  ]
}


resource "null_resource" "k3s121" {

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = templatefile("install.sh", {
      ROOT_CA_PRIVATE_KEY=tls_private_key.root_key.private_key_pem,
      ROOT_CA_PEM_CERT=tls_self_signed_cert.cm_ca_cert.cert_pem,
      INTERMEDIATE_CA_PEM=tls_locally_signed_cert.intermediate_ca.cert_pem,
      INTERMEDIATE_CA_KEY=tls_private_key.intermediate_ca.private_key_pem,
      SERVER_KEY=tls_private_key.server.private_key_pem,
      SERVER_PEM=tls_locally_signed_cert.server.cert_pem,
      CLIENT_KEY=tls_private_key.client.private_key_pem,
      CLIENT_PEM=tls_locally_signed_cert.client.cert_pem,
    })
  }
}
