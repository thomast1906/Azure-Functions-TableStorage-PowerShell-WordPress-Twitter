

    #Create Resource Group & Storage Account Table
    $ResourceGroupName = "tamopsFunctionsTwitter"
    $StorageAccountName = "tamopsfunctionstwittersa"
    $AzureTableName = "tamopsFuncTableBlog"
   
    
        az group create --name $ResourceGroupName --location eastus
        az storage account create --name $StorageAccountName --resource-group $ResourceGroupName --location eastus --sku Standard_LRS

        $saContext = (Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Context
        New-AzureStorageTable –Name $AzureTableName –Context $saContext


    #Create a service principle within AzureAD
    $AzureAdAppPassword = ConvertTo-SecureString '<PASSWORD>' -AsPlainText -Force
    $AzureAdApp = New-AzureRmADApplication -DisplayName "TamOpsFuncADApp" -Password $AzureAdAppPassword -HomePage "https://www.thomasthornton.cloud" -IdentifierUris "https://www.thomasthornton.cloud"


    # Create new service principle and apply permissions
        New-AzureRmADServicePrincipal -ApplicationId $AzureAdApp.ApplicationId | New-AzureRmRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $AzureAdApp.ApplicationId.Guid

    
    # Create Function App and change to version 1
    $FunctionName = "tamopsfunctwitter"
    $ResourceGroupName = "tamopsFunctionsTwitter"
    $StorageAccountName = "tamopsfunctionstwittersa"
    $region = "eastus"

        az functionapp create -n $FunctionName -g $ResourceGroupName --consumption-plan-location $region --storage-account "$StorageAccountName"

        az functionapp config appsettings set -n $FunctionName -g $ResourceGroupName  --settings FUNCTIONS_EXTENSION_VERSION=~1