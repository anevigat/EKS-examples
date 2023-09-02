variable "owner" {
  type    = string
  default = "NCG Digital"
}

variable "env" {
  type    = string
  default = "prod"
}

# AWS Region
variable "region" {
  type = string
}

# EKS Cluster Variables
variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type    = string
  default = "1.27"
}

# EKS Workers Variables
variable "worker_groups" {
  type = list(any)
}

variable "workers_instance_type" {
  type    = string
  default = "t2.medium"
}

variable "workers_root_volume_type" {
  type    = string
  default = "gp3"
}

variable "workers_root_volume_size" {
  type    = string
  default = "30"
}

variable "workers_asg_desired_capacity" {
  type    = string
  default = "2"
}

variable "workers_asg_min_size" {
  type    = string
  default = "2"
}

variable "workers_asg_max_size" {
  type    = string
  default = "3"
}

# EKS IAM roles
variable "admin_role" {
  type    = string
  default = "KubernetesAdmin"
}

variable "dev_role" {
  type    = string
  default = "k8sDev"
}

# AWS CNI
# https://github.com/aws/amazon-vpc-cni-k8s
# https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html#updating-vpc-cni-add-on
# https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
variable "aws_vpc_cni" {
  description = "Enable or disable AWS CNI upgrade and secondary CIDR creation"
  type        = bool
  default     = true
}

variable "aws_cni_version" {
  type    = string
  default = "1.13"
}

# AWS-Calico CNI Add-on
# https://docs.aws.amazon.com/eks/latest/userguide/calico.html
# https://github.com/aws/amazon-vpc-cni-k8s/tree/master/config
# https://docs.projectcalico.org/getting-started/kubernetes/managed-public-cloud/eks
# https://github.com/aws/eks-charts/tree/master/stable/aws-calico
variable "calico_enabled" {
  description = "Enable or disable Calico"
  type        = bool
  default     = true
}

variable "calico" {
  description = "Calico configuration"
  type = object({
    chart      = string
    version    = string
    extra_sets = map(string)
  })
  default = {
    chart   = "https://projectcalico.docs.tigera.io/charts"
    version = "v3.26.0"
    extra_sets = {
      # "image.repository" : "us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler"
      "image.tag" : "v3.26.0"
    }
  }
}

# Cluster Autoscaler
# https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler
# https://github.com/kubernetes/autoscaler/tree/master/charts/cluster-autoscaler
# https://github.com/kubernetes/autoscaler/releases
variable "cluster_autoscaler_enabled" {
  description = "Enable or disable Cluster autoscaler controller installation"
  type        = bool
  default     = false
}

variable "cluster_autoscaler" {
  description = "Cluster autoscaler configuration"
  type = object({
    chart      = string
    version    = string
    extra_sets = map(string)
  })
  default = {
    chart   = "https://kubernetes.github.io/autoscaler"
    version = "9.29.0"
    extra_sets = {
      "image.repository" : "us.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler"
      "image.tag" : "v1.26.2"
    }
  }
}

# Metrics Server
# https://github.com/kubernetes-sigs/metrics-server
# https://github.com/kubernetes-sigs/metrics-server/releases/
# https://github.com/kubernetes-sigs/metrics-server/blob/master/charts/metrics-server/README.md
variable "metrics_server_enabled" {
  description = "Enable or disable metrics server installation"
  type        = bool
  default     = true
}

variable "metrics_server" {
  description = "Resource metrics are used by components like cluster autoscaler, kubectl top and the HPA"
  type = object({
    version    = string
    chart      = string
    extra_sets = map(string)
  })
  default = {
    version = "3.10.0"
    chart   = "https://kubernetes-sigs.github.io/metrics-server/"
    extra_sets = {
      "image.repository" : "k8s.gcr.io/metrics-server/metrics-server"
      "image.tag" : "v0.6.3"
    }
  }
}


# AWS ALB Ingress Controller
# Source: https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller
# Instructions: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/deploy/installation/
variable "aws_load_balancer_controller_enabled" {
  description = "Enable or disable ALB ingress controller installation"
  type        = bool
  default     = false
}

variable "aws_load_balancer_controller" {
  description = "ALB ingress configuration"
  type = object({
    version    = string
    chart      = string
    extra_sets = map(string)
  })
  default = {
    version = "1.5.3"
    chart   = "https://aws.github.io/eks-charts"
    extra_sets = {
      "image.tag" : "v2.5.2"
    }
  }
}

# AWS EBS CSI Driver
# Source: https://github.com/kubernetes-sigs/aws-ebs-csi-driver
# Instructions: https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/install.md
variable "aws_ebs_csi_enabled" {
  description = "Enable or disable EBS CSI driver installation"
  type        = bool
  default     = true
}

variable "aws_ebs_csi_driver" {
  description = "EBS CSI driver configuration"
  type = object({
    version    = string
    chart      = string
    extra_sets = map(string)
  })
  default = {
    version = "2.19.0"
    chart   = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
    extra_sets = {
      "image.tag" : "v1.19.0"
    }
  }
}


# Elastic Agent
# Helm chart WIP: https://github.com/elastic/beats/issues/22572
# https://www.elastic.co/guide/en/fleet/7.14/running-on-kubernetes-standalone.html
# https://www.elastic.co/guide/en/fleet/7.14/dynamic-input-configuration.html
variable "elastic_agent_enabled" {
  description = "Enable install of elastic agent"
  type        = bool
  default     = false
}

variable "elastic_agent_version" {
  description = "Elastic agent image version"
  type        = string
  default     = "8.7.0"
}

variable "elastic_agent_fleet_url" {
  description = "Elastic Operational cluster hostname"
  type        = string
  default     = "https://1149fb8cfd98c8446307a6a5096f6e02.fleet.europe-west2.gcp.elastic-cloud.com:443"
}

variable "elastic_agent_fleet_token" {
  description = "Elastic Operational cluster token"
  type        = string
  default     = ""
}

# Kube-state-metrics
# https://github.com/kubernetes/kube-state-metrics#helm-chart
variable "kube_state_metrics_elastic" {
  description = "Kube state metrics for Elastic Agent"
  type = object({
    version    = string
    chart      = string
    extra_sets = map(string)
  })
  default = {
    version = "5.8.0"
    chart   = "https://prometheus-community.github.io/helm-charts"
    extra_sets = {
      "image.tag" : "v2.9.2"
    }
  }
}

# Descheduler
# https://github.com/kubernetes-sigs/descheduler#install-using-helm
# https://github.com/kubernetes-sigs/descheduler/tree/master/charts/descheduler
variable "descheduler_enabled" {
  description = "Enable or disable Kubernetes descheduler"
  type        = bool
  default     = false
}

variable "descheduler" {
  description = "descheduler"
  type = object({
    version    = string
    chart      = string
    extra_sets = map(string)
  })
  default = {
    version = "0.27.1"
    chart   = "https://kubernetes-sigs.github.io/descheduler/"
    extra_sets = {
      "image.repository" : "k8s.gcr.io/descheduler/descheduler"
      "image.tag" : "v0.26.1"
    }
  }
}


# Argo Workflows
# https://github.com/argoproj/argo-helm/tree/main/charts/argo-workflows
variable "argowf_enabled" {
  description = "Enable or disable Kubernetes argowf"
  type        = bool
  default     = false
}

variable "argowf" {
  description = "argowf"
  type = object({
    version    = string
    chart      = string
    extra_sets = map(string)
  })
  default = {
    version = "0.32.1"
    chart   = "https://argoproj.github.io/argo-helm"
    extra_sets = {
      "image.tag" : "v3.4.9",
      "kubeVersionOverride" : "1.27",
      "crds.keep" : "false",
      "controller.logging.format" : "json",
      "controller.replicas" :"2",
      "server.replicas" : "1",
      "server.logging.format" : "json",
      "server.secure" : "true",
    }
  }
}


# 1Password
# https://developer.1password.com/docs/connect/get-started
# https://github.com/1Password/onepassword-operator
# https://github.com/1Password/connect-helm-charts
variable "onepassword_enabled" {
  description = "Enable or disable 1Password Connect Server and Operator"
  type        = bool
  default     = false
}

variable "onepassword" {
  description = "onepassword"
  type = object({
    version    = string
    chart      = string
  })
  default = {
    version = "1.11.0"
    chart   = "https://1password.github.io/connect-helm-charts/"
  }
}

variable "onepassword_connect_credentials" {
  description = "1password Connect Credentials"
  type        = string
  default     = ""
}

variable "onepassword_operator_token" {
  description = "1password Operator Token"
  type        = string
  default     = ""
}

# Tagging Variables
variable "tags" {
  description = "Additional tags to be applied to all resources created for the AWS resources"
  type        = map(string)
  default     = {}
}


# Grafana Agent
## https://grafana.com/docs/agent/latest/getting-started/
variable "grafana_agent_enabled" {
  description = "Enable install of grafana agent"
  type        = bool
  default     = true
}

variable "grafana_agent_username" {
  description = "Grafana cloud username"
  type        = string
  default     = "283020"
}

variable "grafana_agent_host" {
  description = "Grafana cloud hostname"
  type        = string
  default     = "https://prometheus-prod-01-eu-west-0.grafana.net/api/prom/push"
}

variable "grafana_agent_password" {
  description = "Grafana cloud password"
  type        = string
  default     = ""
}

variable "grafana_loki_enabled" {
  description = "Enable install of grafana loki agent"
  type        = bool
  default     = false
}

variable "grafana_loki_username" {
  description = "Grafana cloud loki username"
  type        = string
  default     = "140481"
}

variable "grafana_loki_host" {
  description = "Grafana cloud hostname"
  type        = string
  default     = "https://logs-prod-eu-west-0.grafana.net/loki/api/v1/push"
}

variable "grafana_agent_version" {
  description = "Grafana agent image version"
  type        = string
  default     = "v0.34.0"
}

# Kube-state-metrics
# https://github.com/kubernetes/kube-state-metrics#helm-chart
variable "kube_state_metrics" {
  description = "Kube state metrics for Grafana Agent"
  type = object({
    version    = string
    chart      = string
    extra_sets = map(string)
  })
  default = {
    version = "5.7.0"
    chart   = "https://prometheus-community.github.io/helm-charts"
    extra_sets = {
      "image.tag" : "v2.9.2"
    }
  }
}