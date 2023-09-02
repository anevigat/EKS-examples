# https://github.com/aws/amazon-vpc-cni-k8s
# https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html#updating-vpc-cni-add-on
# https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
resource "null_resource" "cidr" {
  count = var.aws_vpc_cni != true ? 0 : 1

  triggers = {
    always_run = module.eks.cluster_id
  }

  provisioner "local-exec" {
    on_failure  = fail
    when        = create
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
      echo "Adding secondary CIDR to ${module.eks.cluster_id}"
      echo "Configuring kubeconfig"
      aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_name}
      kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-${var.aws_cni_version}/config/master/aws-k8s-cni.yaml
      kubectl set env ds aws-node -n kube-system AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true
      kubectl set env ds aws-node -n kube-system ENI_CONFIG_LABEL_DEF=topology.kubernetes.io/zone
      kubectl set env ds aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true
      echo "Adding ENIConfig CDR for ${var.region}a"
      kubectl apply -f - <<EOF
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
 name: ${var.region}a
spec:
 subnet: ${module.vpc.private_subnets[3]}
 securityGroups:
 - ${module.eks.cluster_security_group_id}
 - ${module.eks.worker_security_group_id}
EOF
      echo "Adding ENIConfig CDR for ${var.region}b"
      kubectl apply -f - <<EOF
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
 name: ${var.region}b
spec:
 subnet: ${module.vpc.private_subnets[4]}
 securityGroups:
 - ${module.eks.cluster_security_group_id}
 - ${module.eks.worker_security_group_id}
EOF
      echo "Adding ENIConfig CDR for ${var.region}c"
      kubectl apply -f - <<EOF
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
 name: ${var.region}c
spec:
 subnet: ${module.vpc.private_subnets[5]}
 securityGroups:
 - ${module.eks.cluster_security_group_id}
 - ${module.eks.worker_security_group_id}
EOF
    EOT
  }
}