# Planter Infra
This project automates the infrastructure deployment of the planter application.

## Terraform States
Three Terraform states are used, they are stored in the vitr-terraform-states S3 bucket:
- hosted-zone (persisted): users/jordivilagut/planter/hosted-zone/terraform.tfstate
- acm (persisted): users/jordivilagut/planter/acm/terraform.tfstate
- infra (ephemeral): users/jordivilagut/planter/infra/terraform.tfstate

## To deploy the whole infrastructure

1. Deploy the hosted zone (just once, after that it will be persisted)
2. Get the NS records from AWS and set them in your domain registrar
3. Deploy the ACM certificates (just once, after that it will be persisted)
4. Commit and push to deploy the modules

## Infrastructure description

### Hosted Zone
This module creates a Route53 hosted zone for the planter application. It is used to manage the DNS records for the domain.

### Certificates (ACM)
This module creates the ACM certificates for the planter application. It is used to secure the communication between the client and the server.

### VPC
This module provisions a Virtual Private Cloud (VPC) for the Planter application, ensuring resource isolation and secure network connectivity. It includes the following components:
- **Public Subnet:** For resources that need direct internet access.
- **Private Subnets:** For resources that require restricted access.
- **Internet Gateway:** Enables outbound internet connectivity for public resources.
- **NAT Gateway:** Provides internet access for private resources while maintaining security.

### NACL (Network Access Control List)
This module provisions Network Access Control Lists (NACLs) for the Planter application to manage inbound and outbound traffic at the subnet level. It includes the following configurations:  
- **Public NACL:**  
  - Allows HTTP (port 80), HTTPS (port 443), and SSH (port 22) traffic from any source.
  - Allows ephemeral ports (1024-65535) for outbound connections.
- **Private NACL:**  
  - Restricts traffic to and from the VPC's private CIDR block (10.0.0.0/16).
  - Ensures secure communication between private resources.

These NACLs enhance security by providing fine-grained control over network traffic.

### Deployment S3
This module provisions an S3 bucket to store deployment artifacts for the Planter application. It includes the following features:
- **Storage for Deployment Artifacts:** Used to store Terraform state files and application code.
- **Lifecycle Management:** Automatically deletes deployment artifacts older than one day to optimize storage usage.
- **IAM Policy:** Grants EC2 instances read access to the deployment bucket for retrieving necessary files.

### App S3
This module provisions an S3 bucket to store the application code and static files for the planter static website. It includes the following features:
- **Static Website Hosting:** Configures the bucket to serve static websites with an index and error document.
- **Storage for Application Code:** Used to store the application code and static assets.
- **Public Access Restrictions:** Ensures the bucket is not publicly accessible by blocking public ACLs and policies.
- **CloudFront Integration:** Grants access to the bucket through a CloudFront Origin Access Control (OAC) for secure and efficient content delivery.

### SSM
This module provisions an AWS Systems Manager (SSM) Parameter Store for the Planter application. It includes the following features:

- **Environment Variable Management:** Securely stores environment variables required by the application.
- **Configuration Storage:** Provides a centralized location for storing configuration files.
- **IAM Role Integration:**
  - Creates an IAM role (`aws_iam_role`) for EC2 instances to securely interact with SSM.
  - Attaches the `AmazonSSMManagedInstanceCore` policy (`aws_iam_role_policy_attachment`) to grant necessary permissions.
  - Configures an instance profile (`aws_iam_instance_profile`) to associate the IAM role with EC2 instances.
- **Encryption:** Ensures sensitive data is encrypted at rest using AWS-managed or customer-managed keys.

### EC2
This module provisions an EC2 instance for the planter API. It includes the following features:

- **Application Hosting**: Runs the application code and serves static files.
- **IAM Instance Profile**: Associates the instance with an IAM instance profile (`aws_iam_instance_profile`) to securely access AWS resources, such as S3 and SSM.
- **Security Group**: Configures a security group to allow HTTP (port 80) and HTTPS (port 443) traffic, while restricting other inbound traffic.
- **User Data**: Supports initialization scripts through user data for configuring the instance at launch.
- **Public Access**: Associates a public IP address to enable internet access for the instance.
- **Deployment Bucket Access**: Grants the instance read access to the deployment S3 bucket for retrieving necessary files.

### Bastion
This module creates a bastion host for the planter application. It is used to provide secure access to the RDS database.

### Cloudfront
This module creates a CloudFront distribution for the planter application. It is used to provide a CDN for the application code and the static files.

### Route53
This module creates a Route53 record set for the planter application. It is used to map the domain name to the CloudFront distribution.

### RDS
This module creates an RDS database for the planter application. It is used to store the application data and provide a managed database service.

### GitHub
This module provisions GitHub roles and permissions for github to interact with AWS resources securely. It includes the following components:

- **OpenID Connect (OIDC) Provider**: Configures an OIDC provider to enable secure authentication for GitHub Actions workflows.
- **IAM Role for GitHub Actions**: Creates an IAM role that allows GitHub Actions to assume specific permissions for interacting with AWS resources.
- **Policy Attachments**: Grants the following permissions to the GitHub Actions role:
  - Access to SSM for retrieving parameters and sending commands.
  - Access to EC2 for describing instances.
  - Access to S3 for uploading, retrieving, and listing objects.
- **Secure Workflow Integration**: Ensures that only workflows from the `main` branch of the specified GitHub repository can assume the IAM role.

