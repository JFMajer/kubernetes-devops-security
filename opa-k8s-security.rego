package main

deny[res] {
  input.kind == "Deployment"
  not input.spec.template.spec.securityContext.runAsNonRoot = true

  msg := "Containers must not run as root"

  res := {
    "msg": msg,
    "title": "Runs as root user"
  }
}