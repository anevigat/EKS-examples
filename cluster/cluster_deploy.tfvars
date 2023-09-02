### Environment tag ####

## Type: String
# Optioanl - Default "prod"
#env = "dev"


### Kubernetes EKS cluster version ##
### https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html

## Type: Number
# Optional - Default 1.23
#cluster_version = ""


### Workers configuration ###
## https://docs.aws.amazon.com/eks/latest/userguide/choosing-instance-type.html
## https://github.com/aws/amazon-vpc-cni-k8s/blob/release-1.9/pkg/awsutils/vpc_ip_resource_limit.go

# Type: List
# Mandatory (at least 1), add as many blocks as needed
# To remove created worker group, set as_desired_capacity, asg_min_size and asg_max_size to 0
worker_groups = [
  {
    # Mandatory - String - No default
    name = "m5_large"
    # Optional - Default: t2.medium
    instance_type = "m5.large"
    # Optional - Default: gp3
    #    root_volume_type = ""
    # Optional - Default: 50
    #    root_volume_size = ""
    # Optional - Default: 1
    asg_desired_capacity = "3"
    # Optional - Default: 2
    asg_min_size = "3"
    # Optional - Default: 3
    asg_max_size = "10"
  }
]


### AWS CNI ###
## https://github.com/aws/amazon-vpc-cni-k8s
## https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html#updating-vpc-cni-add-on

## Disable AWS CNI upgrade and secondary CIDR creation
# Type: bool
# Optional - Default: true
#aws_vpc_cni = false

## Change AWS CNI version
# Type: string
# Optional - Default: "1.11"
#aws_cni_version = ""


### AWS-Calico CNI Add-on ###
## https://docs.aws.amazon.com/eks/latest/userguide/calico.html
## https://github.com/aws/amazon-vpc-cni-k8s/tree/master/config
## https://docs.projectcalico.org/getting-started/kubernetes/managed-public-cloud/eks

# Type: bool
# Optional - Default: true
#calico_enabled = false


### Cluster Autoscaler ###
## https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler

## Enable cluster autoscaler
# Type: bool
# Optional - Default: false
cluster_autoscaler_enabled = true


### Metrics Server ###
## https://github.com/kubernetes-sigs/metrics-server

## Enable metrics server
# Type: bool
# Optional - Default: true
#metrics_server_enabled = false


### AWS ALB Ingress Controller ###
## Source: https://github.com/aws/eks-charts/tree/master/stable/aws-load-balancer-controller
## Instructions: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/deploy/installation/

## Enable ALB Ingress Controller
# Type: bool
# Optional - Default: false
aws_load_balancer_controller_enabled = true

### AWS EBS CSI Driver Controller ###
## Source: https://github.com/kubernetes-sigs/aws-ebs-csi-driver
## Instructions: https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/install.md

## Enable EBS CSI Driver Controller
# Type: bool
# Optional - Default: true
#aws_ebs_csi_enabled = false

### Kubernetes Cluster Descheduler ###
## https://github.com/kubernetes-sigs/descheduler#install-using-helm
## https://github.com/kubernetes-sigs/descheduler/tree/master/charts/descheduler

## Enable Descheduler
# Type: bool
# Optional - Default: false
descheduler_enabled = true

### Argo Workflows ###
## https://github.com/argoproj/argo-helm/tree/main/charts/argo-workflows

## Enable Argo Workflows
# Type: bool
# Optional - Default: false
argowf_enabled = true

### 1Password Integration ###
# https://developer.1password.com/docs/connect/get-started
# https://github.com/1Password/onepassword-operator
# https://github.com/1Password/connect-helm-charts

## Enable 1Password Connect Server and Operator
# Type: bool
# Optional - Default: false
onepassword_enabled = true

### Grafana Agent ###
## https://grafana.com/docs/agent/latest/getting-started/

## Enable Grafana Agent and kube_state_metrics installation
# Type: bool
# Optional - Default: true
#grafana_agent_enabled = false

## Enable Grafana Loki Agent to collect all POD's logs
# Type: bool
# Optional - Default: false
#grafana_loki_enabled = true


### Elastic Agent ###
## Enable Elastic Agent and kube_state_metrics installation
# Type: bool
# Optional - Default: false
elastic_agent_enabled = true