# terragrunt-starter-kit

## About this project

This repository contains the foundational structure, configuration files, and best practices for setting up and managing infrastructure using Terragrunt and Terraform on AWS. The resources are organized in four environments: 

  1. Management
  2. Monitoring
  3. Development
  4. Production

- The Management account serves as the root of the AWS Organization, from where we create the organizational units and manage all other accounts. 
- The Monitoring account is responsible for security and monitoring.
- The Production and Development accounts host application workloads, provisioning an EKS cluster along with its dependencies

## How to set up

To deploy this project, navigate to the appropriate environment folder (e.g., management, monitoring, development, or production) and execute the following commands:

```
# 1. Initialize Terragrunt, pulling in any required modules and configurations
terragrunt init

# 2. Run a plan to preview the infrastructure changes
terragrunt plan

# 3. Apply the changes to deploy resources to the specified environment
terragrunt apply
```


> **Note**: Before deploying, ensure the following prerequisites are met:
>
> - **AWS Credentials**: Your AWS credentials are configured and have the necessary permissions to manage resources in each environment.
> - **Terragrunt and Terraform**: Both tools should be installed and accessible in your command line.
> - **Backend Configuration**: Verify that the remote backend (e.g., S3 for state storage) is properly configured in each environment's `terragrunt.hcl` file to avoid state conflicts.
> - **Dependencies**: Some environments (e.g., Production) may have dependencies on resources provisioned in other environments, such as networking components from the Management account. Deploy environments in the recommended order if dependencies exist.
