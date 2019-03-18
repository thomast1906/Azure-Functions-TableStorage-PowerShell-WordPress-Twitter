    $ResourceGroupName = "tamopsFunctionsTwitter"
    $FunctionName = "tamopsfunctwitter"

    $AppSettingsHash = @{
    ResourceGroupName = $ResourceGroupName
    StorageAccountName = "tamopsfunctionstwittersa"
    AzureTableName = "tamopsFuncTable"
    partitionKey = "twitterPartKey"
    BlogSiteName = "thomasthornton.cloud"
    twitterID= "tamstar1234"
    twitterAccessToken = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    twitterAccessTokenSecret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    twitterAPIKey = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    twitterAPISecret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    AzureADTenantId = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    AzureADAppUser = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    AzureADAppPassword = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    AzureTableAzureTablePartitionKey = "twitterPartKey"
    }

    foreach ($AppSettingAdd in $AppSettingsHash.GetEnumerator()) {
    az functionapp config appsettings set --resource-group $ResourceGroupName --name $FunctionName --settings "$($AppSettingAdd.Name) = $($AppSettingAdd.Value)"
    }