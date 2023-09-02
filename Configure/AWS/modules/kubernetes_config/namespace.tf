resource "kubernetes_namespace" "namespace" {
  metadata {
    labels = {
      owner                                     = var.owner
      env                                       = var.env
      name                                      = var.name
      "elbv2.k8s.aws/pod-readiness-gate-inject" = var.readiness_gate ? "enabled" : null
    }

    annotations = {
     "pod-security.kubernetes.io/enforce"         = "baseline"
     "pod-security.kubernetes.io/enforce-version" = "latest"
     "pod-security.kubernetes.io/warn"            = "restricted"
     "pod-security.kubernetes.io/warn-version"    = "latest"
     "pod-security.kubernetes.io/audit"           = "restricted"
     "pod-security.kubernetes.io/audit-version"   = "latest"
    }

    name = var.name
  }
}