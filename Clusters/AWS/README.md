# Deploy EKS on AWS with Terrafom

## Intro
This folder contains terraform manifests and some additionals files to deploy a production kubernetes cluster on the Elastic Kubernetes Service provided by AWS

## Terraform providers
| Name | Version |
|------|---------|
|Terraform|v.1.3.0|
|hashicorp/aws|4.14.0|
|hashicorp/null|3.1.1|
|hashicorp/kubernetes|2.21.1|
|hashicorp/helm|2.5.1|

## Terraform modules
| Name | Version |
|------|---------|
|terraform-aws-modules/vpc/aws|3.14.0|
|terraform-aws-modules/eks/aws|17.22.0|

## Components overview
To create a production-grade kubernetes clustes, some additional components and add-ons will be installed by default:
- Upgraded AWS VPC CNI version
- Secondary CIDR for PODs allocation
- AWS Calico for implementing network policies
- Custom AIM role for administration users access
- Cluster Autoscaler Controller (with custom IAM roles)
- AWS Load Balancer nginx Controller (with custom IAM roles)
- Metrics Server for autoscaling feature
- Kube State Metris for cluster wide metrics collection
- Descheduler to rebalance PODs
- 1Password Connect Server and 1Password Operator
- Elastic Agent to send metrics and logs to the prd-operational elastic on-cloud cluster
- Grafana Agent to send metrics and logs to Grafana Cloud

## Components versions
| Name | Version | Helm Chart |
|------|---------|------------|
|EKS|1.27|n/a|
|AWS VPC CNI|1.12|n/a|
|Calico for AWS|v3.26.1|3.26.1|
|Cluster Autoscaler|v1.26.2|9.29.0|
|Metrics Server|v0.6.3|3.10.0|
|AWS Load Balancer Controller|v2.5.2|1.5.3|
|AWS EBS CSI Driver|v1.19.0|2.19.0|
|Elastic agent|8.7.0|n/a|
|Descheduler|v0.26.1|0.27.1|
|1Password|1.11.0|1.6.0|
|Grafana Agent|0.34.0|n/a|
|Kube State Metrics|v2.9.2|5.8.0|

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| owner | Tag to attach to all created resources | `string` | Owner |
| env | Tag to attach to all created resources | `string` | prod |
| region | AWS region to deploy resources | `string` | n/a |
| cluster_name | Name of the EKS cluster | `string`| n/a |
| cluster_version | EKS cluster version | `string` | 1.22 |
| worker_groups | Workers group variables definition | `list` | n/a |
| workers_instance_type | Workers instance type | `string` | t2.medium |
| workers_root_volume_type | Workers root volume type | `string` | gp3 |
| workers_root_volume_size | Workers root volume size | `string` | 30 |
| workers_asg_desired_capacity | Workers autoscaling group desired initial number | `string` | 2 |
| workers_asg_min_size | Workers autoscaling group min number | `string` | 2 |
| workers_asg_max_size | Workers autoscaling group max number | `string` | 3 |
| admin_role | Cluster admin AIM role | `string` | KubernetesAdmin |
| dev_role | Cluster developers AIM role | `string` | k8sDev |
| aws_vpc_cni | Enable or disable AWS CNI upgrade and secondary CIDR creation | `bool` | true |
| aws_cni_version | AWS VPC CNI version | `string` | 1.11 |
| calico_enabled | Enable Calito | `bool` | true |
| cluster_autoscaler_enabled | Cluster autoscaler enabled | `bool` | false |
| cluster_autoscaler | Cluster autoscaler configuration | `object` | yes |
| metrics_server_enabled | Metrics server enabled | `bool` | true |
| metrics_server | Resource metrics are used by components like cluster autoscaler, kubectl top and the HPA | `object` | yes |
| aws_load_balancer_controller_enabled | AWS Load Balancer nginx ingress Controller enabled | `bool` | false |
| aws_load_balancer_controller | AWS Load Balancer nginx ingress Controller | `object` | yes |
| aws_ebs_csi_enabled | AWS EBS CSI driver enabled | `bool` | false |
| aws_ebs_csi_driver | AWS EBS CSI driver | `object` | yes |
| elastic_agent_enabled | Enable elastic agent and kube_state_metrics | `bool` | false |
| elastic_agent_fleet_token | Elastic Operational cluster Fleet token | `string` | n/a |
| elastic_agent_fleet_url | Elastic Operational cluster hostname | `string` | https://1149fb8cfd98c8446307a6a5096f6e02.fleet.europe-west2.gcp.elastic-cloud.com:443 |
| elastic_agent_version | Elastic agent image version | `string` | 7.15.1 |
| kube_state_metrics_elastic | For cluster wide metrics collection - To be used by the elastic agent | `object` | yes |
| grafana_agent_enabled | Enable grafana agent and kube_state_metrics | `bool` | false |
| grafana_agent_username | Grafana Cloud username | `string` | 283020 |
| grafana_agent_password | Grafana Cloud password | `string` | n/a |
| grafana_agent_host | Grafana Cloud hostname | `string` | https://prometheus-prod-01-eu-west-0.grafana.net/api/prom/push |
| grafana_agent_version | Grafana agent image version | `string` | 0.24.1 |
| grafana_loki_enabled | Enable grafana loki agent | `bool` | false |
| grafana_loki_username | Grafana Cloud loki username | `string` | 140481 |
| grafana_loki_host | Grafana Cloud loki hostname | `string` | https://logs-prod-eu-west-0.grafana.net/api/prom/push |
| kube_state_metrics_grafana | For cluster wide metrics collection - To be used by the grafana agent | `object` | yes |
| descheduler_enabled | Enable descheduler to rebalance cluster automatically | `bool` | true |
| descheduler | Used to rebalance cluster | `object` | yes |
| onepassword_enabled | Enable 1Password Connect and Operator | `bool` | false |
| onepassword | Used sync secrets between 1Password and Kubernetes secrets | `object` | yes |


## Local execution

### Requirements
- Terraform version `v1.3.0`
- kubectl
- AWS cli
- AWS credentials with permissions to create an EKS cluster on AWS and access to terraform state s3 buckets
- (Optional): Password for sending metrics and logs to the prd-operational elasticsearch on-cloud cluster
- (Optional): 1Password account

### Usage
- Run ```terraform init``` to initialize providers, modules and s3 backend:
```
terraform init -backend-config 'key=eks/eu-west-1-test_cluster/terraform.tfstate'
```

- Edit ```cluster_deploy.tfvars``` located in the *files/tfvars* folder
- Run ```terraform plan``` and analize output
```
TF_VAR_region=eu-west-1 TF_VAR_cluster_name=test_cluster terraform plan -var-file=files/tfvars/cluster_deploy.tfvars
```
- Run ```terraform apply``` to apply changes
```
TF_VAR_region=eu-west-1 TF_VAR_cluster_name=test_cluster terraform apply -var-file=files/tfvars/cluster_deploy.tfvars
```
- When finished, run ```terrafom destroy``` to delete created resources

