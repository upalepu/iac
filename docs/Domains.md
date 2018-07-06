# Infrastructure as Code - Domains & DNS Considerations

Note that Kubernetes needs a domain name to work properly. If you want to use the ***kubernetes*** project, you will need an external domain name either in *Route53* or from a 3rd party Domain name provider like *godaddy*. If you don't have a domain name or don't want to purchase one, you should use the ***k8sgossip*** project to create your Kubernetes cluster. See below for additional information.

## When using ***k8sgossip*** project

If you don't have an external domain name or don't wan't to pay for it, you should use the ***k8sgossip*** project in ***iac***. This project sets up a Kubernetes cluster using the *Gossip* based protocol *[Weave Mesh](https://github.com/weaveworks/mesh)*. It allows you to play with Kubernetes without requiring an external domain name. It creates the cluster as *awsaccountalias.k8s.local*, where *awsaccountalias* is your AWS account login name.

## When using ***kubernetes*** project

In order for Kubernetes to work properly, you need to setup DNS (Domain Name Server) correctly. The ***kubernetes*** project in ***iac*** assumes you have a domain registered with AWS. It typically costs ~$1/month to register a domain on AWS.

The project creates a subdomain called ***kubernetes*** and uses that for the kubernetes cluster DNS information. This ensures that your domain is not affected in any way by this project.

If you have your own domain registered with another provider, there are manual steps which can be done to setup the domain name. Instructions will be provided on this topic in a later update.
