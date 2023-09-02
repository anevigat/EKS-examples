# Configure EKS on AWS with Terrafom

## Intro
This folder contains terraform manifests and some additionals files to configure namespaces, RBAC resources, network policies and ingresses

**IMPORTANT:** No action will be triggered from this repo. To configure a cluster, check this [repository]()

## Terraform providers
| Name | Version |
|------|---------|
|Terraform|v.1.1.9|
|hashicorp/aws|4.14.0|
|hashicorp/kubernetes|2.11.0|
|cloudflare|3.15.0|

## Terraform modules
| Name | Location |
|------|----------|
|kubernetes_config|local|

## Global Inputs
| Name | Description | Type | Default |
|------|-------------|------|---------|
| owner | Tag to attach to all created resources | `string` | owner |
| region | AWS region to deploy resources | `string` | n/a |
| cluster_name | Name of the EKS cluster | `string`| n/a |

## Module Inputs
| Name | Description | Type | Default |
|------|-------------|------|---------|
| owner | Tag to attach to all created resources | `string` | owner |
| env | Tag to attach to all created resources | `string` | prod |
| cluster_name | Name of the EKS cluster | `string`| n/a |
| role_read_write | Create a role with write permissiong and attach it to `user` | `bool` | false |
| user | User to attach the read or read_write roles | `string` | dev-user |
| np_deny-to-nodes | Create network policy to deny access from Pods to Nodes | `bool` | true |
| np_deny-from-other-ns | Create network policy to deny access from other namespaces | `bool` | true |
| network_policies_ingress | Create network policy for ingress resources | `map(object)` | {} |
| ingress | Create ingress resource | `map(object)` | {} |

## Local execution

### Requirements
- Terraform version `v1.1.9`
- kubectl
- AWS cli
- AWS credentials with permissions to create an EKS cluster on AWS and access to terraform state s3 buckets

### Usage
- Run ```terraform init``` to initialize providers, modules and s3 backend:
```
terraform init -backend-config 'key=eks-config/eu-west-1_k8s/terraform.tfstate'
```

- For every namespace that you want to create, copy the ```namespace_example.tf``` file to a new file
- Edit the namespace configuration
- Run ```terraform plan``` and analize output
```
TF_VAR_region=eu-west-1 TF_VAR_cluster_name=test_cluster terraform plan
```
- Run ```terraform apply``` to apply changes
```
TF_VAR_region=eu-west-1 TF_VAR_cluster_name=test_cluster terraform apply
```
- When finished, run ```terrafom destroy``` to delete the created resources