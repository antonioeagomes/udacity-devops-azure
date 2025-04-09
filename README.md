# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

## 📘 Project Overview

This project demonstrates how to automate the deployment of a scalable web server infrastructure on Microsoft Azure using **Packer** and **Terraform**.

The infrastructure includes:
- A custom VM image built with Packer
- A load balancer distributing traffic across multiple VMs
- A virtual network with proper subnetting and security rules
- A scalable number of VMs managed via a variable

---

### Getting Started
### 1. Clone the repository

```bash
git clone https://github.com/antonioeagomes/azure-terraform-packer-project.git
cd azure-terraform-packer-project
```
### 2. Azure login
```bash
az login
az account show
```
### 3. Set up Azure Service Principal (One-Time Setup)
```bash
az ad sp create-for-rbac --name "PackerTerraformSP" --role Contributor --scopes /subscriptions/YOUR_SUBSCRIPTION_ID --sdk-auth
```
⚠️ Save the JSON output - these are your credentials

⚠️ Replace YOUR_SUBSCRIPTION_ID with your actual Azure Subscription ID

    
## 4. Assure that you have the Resource group in your closest loaction. 
```bash
az group create --name udacity-devops-rg --location "westeurope"
```

## 5. Set up your environment file
```bash
ARM_CLIENT_ID="<clientId>"
ARM_CLIENT_SECRET="<clientSecret>"
ARM_SUBSCRIPTION_ID="<subscriptionId>"
ARM_TENANT_ID="<tenantId>"
```

## 6. Load Environment variables
Run the load script before any Packer/Terraform operations:
```bash 
.\load-env.ps1
```        

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
### 🧱 Step 1: Build Packer ImagePacker Image Build
```bash
cd packer-template
packer validate server.json
packer build server.json
cd ..
```
> 🔎 After the build completes, copy the ManagedImageId from the output.
>
>       ManagedImageId: /subscriptions/xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx/ resourceGroups/myResourceGroup/providers/Microsoft.Compute/images/myPackerImage

### 🌍 Step 2: Deploy Infrastructure with Terraform
```bash 
cd terraform-template
terraform init
terraform plan -var="packer_image_id=<your_image_id>"
terraform apply -var="packer_image_id=<your_image_id>"
cd ..
```
>💡 Replace <your_image_id> with the ManagedImageId from the previous step.  

### 🔍 Output & Verification
* Log in to the Azure Portal to verify your infrastructure
* Retrieve the web server endpoint:
    ```bash
    terraform output -raw web_endpoint
    ```
* Paste the endpoint into your browser to confirm your app is running.


### 🔐 Important Security Notes:
* Never commit `.env` to version control
* Add `.env` to your `.gitignore` file
* Restrict Service Principal permissions to only required resources
* Rotate credentials periodically using:
    ```bash
    az ad sp credential reset --name "PackerTerraformSP"
    ```

### 📁 Project Structure

.
├── packer-template/
│   └── server.json
├── terraform-template/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── ...
├── .env
├── load-env.ps1
└── README.md