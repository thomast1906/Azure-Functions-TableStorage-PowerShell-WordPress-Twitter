    $Username = $env:AzureADAppUsername
    $AzureADTenantId  = $env:AzureTenantId
    $AzureADAppPassword = ConvertTo-SecureString $env:AzureADAppPassword -AsPlainText -Force
    $Credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username, $AzureADAppPassword

        Login-AzureRmAccount -ServicePrincipal -Credential $Credential -TenantId $AzureADTenantId
 
    $BlogSiteName = $env:BlogSiteName
    $ResourceGroupName = $env:ResourceGroupName
    $StorageAccountName = $env:StorageAccountName
    $AzureTableName = $env:AzureTableName
    $AzureTableAzureTablePartitionKey = $env:AzureTableAzureTablePartitionKey

    
    #Get Storage Context to add Blog URL/details to
    $saContext = (Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Context   
    $TableContext = Get-AzureStorageTable -Name $AzureTableName -Context $saContext


    # Adds Blogs to Table Storage
    $BlogPostsSearch = Invoke-RestMethod -uri "https://public-api.wordpress.com/rest/v1/sites/$BlogSiteName/posts/?number=100"

        foreach ( $BlogPostsAdd in $BlogPostsSearch.posts) {

            $urlcheck = $BlogPostsAdd.URL
            $CheckURLColumn = Get-AzureStorageTableRowByCustomFilter -table $TableContext -customFilter "(URL eq '$urlcheck')"

            if ($CheckURLColumn -eq $null){
            
            Write-Output "Adding Blog Post: $urlcheck"
            Add-StorageTableRow -table $TableContext -partitionKey $AzureTableAzureTablePartitionKey -rowKey ([guid]::NewGuid().tostring()) -property @{"Update"=$BlogPostsAdd.Title;"URL"=$BlogPostsAdd.URL;"Tweeted"="No"}

            }
        }