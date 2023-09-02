# AWS Container Registry

## Description

Terraform manifest to maintain AWS elastic container registry (ECR) repositories

## Repo usage

- Create new branch from ```terraform/AWS_container_registry``` branch
- Add changes to ```terraform.tfvars``` file, push them to the newly created branch and create PR against ```terraform/AWS_container_registry``` branch
- Review ```terraform plan``` executed on the github actions workflow
- If plan is OK, approve changed and merge into ```terraform/AWS_container_registry``` branch
