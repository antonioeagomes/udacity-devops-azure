# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Repository setup
    * Clone this repository
    * Open PowerShell or Bash and navigate to the project directory

2. Azure login
    * Connect to your Azure account
    `az login`
    * Verify your subscription
    `az accounts show`
3. Set up Azure Service Principal (One-Time Setup)
        
        `az ad sp create-for-rbac --name "PackerTerraformSP" --role Contributor --scopes /subscriptions/YOUR_SUBSCRIPTION_ID --sdk-auth?`

    * Save the JSON output - these are your credentials

        Note: Replace YOUR_SUBSCRIPTION_ID with your actual Azure Subscription ID

4. Create environment file
    * In your project root folder: `New-Item -Path .\.env -ItemType File`
        
        Add these variables (use values from Service Principal creation):

        >``ARM_CLIENT_ID="<clientId>"
        >ARM_CLIENT_SECRET="<clientSecret>"
        >ARM_SUBSCRIPTION_ID="<subscriptionId>"
        >ARM_TENANT_ID="<tenantId>"``

5. Load Environment variables
    * Run the load script before any Packer/Terraform operations:
    
        `.\load-env.ps1`

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
1. Packer Image Build

        cd packer-template
        packer validate server.json
        packer build server.json
        cd ..
2. Save Packer Image Id
    * In the Packer output

            ==> Builds finished. The artifacts of successful builds are:
            --> azure-arm: Azure.ResourceManagement.VMImage:
            ManagedImageResourceGroupName: myResourceGroup
            ManagedImageName: myPackerImage
            ManagedImageId: /subscriptions/xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.Compute/images/myPackerImage

    * Store the ManagedImageId
            
            $imageId = "/subscriptions/xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx/resourceGroups/myResourceGroup/providers/Microsoft.Compute/images/myPackerImage"

3. Terraform deployment
        
        cd terraform-template
        terraform init
        terraform plan -var="packer_image_id=$imageId"
        terraform apply -var="packer_image_id=$imageId"
        cd ..


### Output
1. Verify on Azure Portal
2. Get endpoint
    * `terraform output -raw web_endpoint`


### Important Security Notes:
* Never commit .env to version control
* Add .env to your .gitignore file
* Restrict Service Principal permissions to only required resources
* Rotate credentials periodically using:

    `az ad sp credential reset --name "PackerTerraformSP"`