# This file contains variables which are referenced and used by the various terraform
# configuration files in this project.
# Most commonly needed variable are included here. 
# Changing the value in the variable will enable a different configuration to be created.
# See individual variable descriptions for information on how to change variables. 
variable "k8scfg" {
    type = "map"
    description = "AWS Configuration information for setting up a Kubernetes Cluster"
    default = {
        tags_project = "demo-kubernetes"
        tags_provider = "aws"
        parm_region = "us-east-1"
        parm_domain = "example.com"
        parm_subdomain = "kubernetes"
        parm_comment = "Kubernetes cluster subdomain" 
        parm_group = "kopsgroup"
        parm_user = "kops"
        parm_versioning = "false"
        md_force_destroy = "false" # Experimental. "true" if "user" has to be deleted even if it has non-terraform access keys.
    }
}