# Project Title

Example of Consul cluster provisioning in AWS using Hashicorp's Terraform and Packer

## Instructions

### Prerequisites
Following must be installed and configure on your local machine:
  - Terraform
  - Packer

1. Create AWS User to use with EC2
2. Create `aws_conf.sh` file based on `aws_conf.sh.template`. Fill in necessary values. These will be used by Packer and Terraform during packaging and provisioning.
2. Create `consul/consul.d/config.json` file from `consul/consul.d/config.json.template`. Insert AWS key info (required for Consul auto discovery feature to function properly)
3. Run following command to package AMI image: `sh ./bin/run_packer_build.sh`. Note AMI ID in output of the script. You will need it for the following step.
4. Run following command to provision Consul cluster: `terraform apply -var "access_key=$AWS_ACCESS_KEY_ID" -var "secret_key=$AWS_SECRET_ACCESS_KEY" -var ami=<AMI ID from step #3>`
