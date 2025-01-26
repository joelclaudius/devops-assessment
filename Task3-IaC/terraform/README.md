# **Infrastructure as Code (IaC) for AWS Deployment**

This repository contains a **Terraform configuration** to automate the deployment of infrastructure resources on **AWS**. The resources include a **Virtual Private Cloud (VPC)**, an **EC2 instance**, and a **Security Group**, all of which are modular and can be reused in various configurations.

The goal of this project is to showcase best practices in **Infrastructure as Code (IaC)** using Terraform, and to deploy infrastructure in a highly modular way that allows for easy customization and extension.

---

## **Project Structure**

The directory structure of the project is organized into modules, with each module handling a specific resource or set of resources. Below is a breakdown of the project structure:

```plaintext
terraform/
├── main.tf             # Entry point for Terraform execution
├── variables.tf        # Variables declaration
├── outputs.tf          # Outputs for the infrastructure
├── provider.tf         # Provider configuration (AWS)
├── modules/
│   ├── vpc/
│   │   ├── main.tf      # VPC resources
│   │   ├── variables.tf # VPC-specific variables
│   │   ├── outputs.tf   # VPC outputs
│   ├── ec2/
│   │   ├── main.tf      # EC2 resources
│   │   ├── variables.tf # EC2-specific variables
│   │   ├── outputs.tf   # EC2 outputs
│   ├── security_group/
│   │   ├── main.tf      # Security group resources
│   │   ├── variables.tf # SG-specific variables
│   │   ├── outputs.tf   # SG outputs

```

### Description of Files:

- **main.tf**: The entry point of the Terraform configuration where resources are instantiated via modules.
- **variables.tf**: This file defines all the variables used across the project. It includes resource-specific variables like region, key name, and VPC CIDR block.
- **outputs.tf**: Defines the outputs that Terraform will provide after the resources are created. These could be things like VPC IDs, EC2 public IPs, etc.
- **provider.tf**: Specifies the AWS provider and region for Terraform to operate in. This is the configuration needed for interacting with AWS resources.
- **modules/**: Contains the reusable modules for each resource type (VPC, EC2, Security Group).

### Module Overview:

- **vpc**: This module defines the resources for creating a VPC, including the CIDR block, subnets, and route tables.
- **ec2**: This module creates an EC2 instance and associates it with the specified security group and subnet.
- **security_group**: This module defines a security group with rules for allowing inbound HTTP and HTTPS traffic.

### Project Diagram

Below is a visual representation of the project structure, showing how each module and resource is interconnected:

```plaintext
terraform/
├── main.tf       <-- Entry point for the execution, calls modules
├── provider.tf   <-- AWS Provider configuration
├── variables.tf  <-- Variable definitions for customizing deployment
├── outputs.tf    <-- Output values for deployed resources
├── modules/
│   ├── vpc/      <-- Defines VPC-related resources
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ec2/      <-- Defines EC2-related resources
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── security_group/  <-- Defines security group resources
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
```

### Requirements

- **Terraform**: 0.13 or later
- **AWS Account**: You must have access to an AWS account with appropriate permissions to create EC2 instances, VPCs, and security groups.

### Setup Instructions

1. **Clone the Repository**: Clone this repository to your local machine:

   ```bash
   git clone https://github.com/joelclaudius/devops-assessment.git
   cd devops-assessment/Task3-IaC/terraform
   ```

2. **Configure AWS Credentials**: Ensure you have your AWS credentials configured. You can configure your credentials using the AWS CLI:

   ```bash
   aws configure
   ```

   Or by editing the `~/.aws/credentials` and `~/.aws/config` files directly.

3. **Initialize Terraform**: Run the following command to initialize the Terraform working directory and download the required providers:

   ```bash
   terraform init
   ```

4. **Review the Plan**: To see what Terraform will do before making any changes, run:

   ```bash
   terraform plan -var="key_name=your-key-name"
   ```

   Ensure you replace `your-key-name` with your actual AWS key pair name.

5. **Apply the Terraform Plan**: Once you’re happy with the plan, apply it to provision the resources:

   ```bash
   terraform apply -var="key_name=your-key-name"
   ```

6. **View Outputs**: After the resources are created, you can view the output values (e.g., VPC ID, EC2 public IP) with:

   ```bash
   terraform output
   ```

### Clean Up

To destroy the resources and clean up the infrastructure, run the following command:

```bash
terraform destroy
```
