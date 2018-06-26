# Infrastructure as Code - Domains & DNS Considerations

In order for Kubernetes to work properly, you need to setup DNS (Domain Name Server) correctly. The ***kubernetes*** project in ***iac*** assumes you have a domain registered with AWS. It typically costs ~$1/month to register a domain on AWS.

The project creates a subdomain called kubernetes and uses that for the kubernetes cluster DNS information. This ensures that your domain is not affected in any way by this project.

If you have your own domain registered with another provider, there are manual steps which can be done to setup the domain name. Instructions will be provided on this topic in a later update.
