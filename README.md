# Kubernetes_config

## Intro
This **multibranch** repo contains the configuration files to deploy and configure Kubernete on-cloud

## Available cloud providers
- EKS on AWS

## Create a kubernetes cluster

### **Prepare the branch**
This branch will hold all the settings files to deploy and configure the cluster

- Checkout to the template branch depending on the cloud you want to use. Currently available:
```template_eks_aws```

- Create a new branch from selected template with the following ***Branch name format***:
```<KUBERNETES_CLOUD_SERVICE>/<CLOUD_REGION>/<CLUSTER_NAME>```. For example:
```
git checkout -b eks/eu-west-1/k8s
```

**IMPORTANT:** Cluster name and cloud region will be extracted from the branch name. Make sure you set the right values!

- Create and empty commit and push newly created branch with the following ***Commit message***:
```"Initial commit [no ci]"```

### **Set the cluster deployment settings and deploy cluster**
On this step, a new kubernetes cluster will be deployed.
- Create a new branch from the newly created branch with the following ***Branch name format***:
```<JIRA_TICKET>_<CLOUD_REGION>_<CLUSTER_NAME>```. For example:
```
git checkout eks/eu-west-1/k8s
git checkout -b ND-211_eu-west-1_k8s
```

- Edit the ***cluster_deploy.tfvars*** file within the ***cluster*** folder with the desired configuration.

- Push changes

- Create pull request to the appropiate original branch. This will trigger a ***github actions workflow*** and a ***terraform plan*** will be executed.

- Review the ***terraform plan output***, make sure that only your desired changes will be applied.

- Approve pull request and merge changes.

- Another *github action workflow* will be trigger, this time executing a ***terraform apply***

- Verify all actions end successfully

### **Set cluster configuration settings and apply them**
This step will create the desired namespaces, user roles, network policies and ingress resources (optional).
- Use the branch created in the previous step

- For every namespace that you want to create, copy the ***namespace_example.tf*** file within the ***config*** folder to a new file with the name of the namespace and place it on the same folder. For example:
```
cp config/namespace_example.tf config/main.tf
cp config/namespace_example.tf config/staging.tf
cp config/namespace_example.tf config/development.tf
```

- Edit each namespace file with the desired configuration

- Push changes

- Create pull request to the appropiate original branch. This will trigger a ***github actions workflow*** and a ***terraform plan*** will be executed.

- Review the ***terraform plan output***, make sure that only your desired changes will be applied.

- Approve the pull request and merge changes.

- Another *github action workflow* will be trigger, this time executing a ***terraform apply***

- Verify all actions end successfully

## Modify a running kubernetes cluster

- Create new branch from the original configuration branch with the following ***Branch name format***:
```<JIRA_TICKET>_<CLOUD_REGION>_<CLUSTER_NAME>```. For example:

```
git checkout eks/eu-west-1/k8s
git checkout -b ND-211_eu-west-1_k8s
```

- If you want to change the cluster deployment, modify the ***cluster_deploy.tfvars*** file within the ***cluster*** folder with the desired configuration changes.

- If you want to change the namespaces current configuration, modify the ***<NAMESPACE_NAME>.tf*** file within the ***config*** with the desired configuration changes.

- If you want to create a new namespace and all it's resources, copy the ***namespace_example.tf*** file within the ***config*** folder to a new file with the name of the namespace, place it on the same folder and edit each new namespace file with the desired configuration

- Push changes

- Create pull request to the appropiate original branch. This will trigger a ***github actions workflow*** and a ***terraform plan*** will be executed.

- Review the ***terraform plan output***, make sure that only your desired changes will be applied.

- Approve the pull request and merge changes.

- Another *github action workflow* will be trigger, this time executing a ***terraform apply***

- Verify all actions end successfully

## Delete a previously deployed kubernetes cluster
to be defined...
