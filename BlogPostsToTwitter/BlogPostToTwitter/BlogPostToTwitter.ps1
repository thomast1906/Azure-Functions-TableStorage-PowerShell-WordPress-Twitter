    $AzureADTenantId  = $env:AzureTenantId
    $Username = $env:AzureADAppUsername
    $AzureADTenantId  = $env:AzureTenantId
    $AzureADAppPassword = ConvertTo-SecureString $env:AzureADAppPassword -AsPlainText -Force
    $Credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username, $AzureADAppPassword

        Login-AzureRmAccount -ServicePrincipal -Credential $Credential -TenantId $AzureADTenantId

            
    $ResourceGroupName = $env:ResourceGroupName
    $StorageAccountName = $env:StorageAccountName
    $AzureTableName = $env:AzureTableName
    $twitterID = $env:twitterID
    $twitterAccessToken = $env:twitterAccessToken
    $twitterAccessTokenSecret = $env:twitterAccessTokenSecret
    $twitterAPIKey = $env:twitterAPIKey
    $twitterAPISecret = $env:twitterAPISecret


    #Get Storage Context to add Blog URL/details to
    $saContext = (Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Context   
    $TableContext = Get-AzureStorageTable -Name $AzureTableName -Context $saContext


    #Check for Available Tweets

    $AvailableTweets = Get-AzureStorageTableRowByCustomFilter -table $TableContext -customFilter "(Tweeted eq 'No')"

        if ($AvailableTweets -eq $null){

            $AvailableTweetsCHECK = Get-AzureStorageTableRowByCustomFilter -table $TableContext -customFilter "(Tweeted eq 'Yes')"

        foreach ($tweetedReplace in $AvailableTweetsCHECK) {

            "No Available Tweets, refreshing tweeted column to No"
            $tweetedReplace.tweeted = "No"
            $tweetedReplace | Update-AzureStorageTableRow -table $TableContext
           
            }
        }


    #Blog Post To Twitter
    $TweetUpdate = Get-AzureStorageTableRowAll -table $TableContext 

    $TweetToSend = $TweetUpdate | ?{$_.tweeted -ne 'Yes'} | get-random 

    $IDtoChange = $TweetToSend.URL
    $IDChange = Get-AzureStorageTableRowByCustomFilter -table $TableContext -customFilter "(URL eq '$IDtoChange')"
    $IDChange.tweeted = "Yes"
    $IDChange | Update-AzureStorageTableRow -table $TableContext
    

    #Setup Twitter OAuth Hashtable
    $TwitterOAuthConfig = @{ 'ApiKey' = $twitterAPIKey; 'ApiSecret' = $twitterAPISecret; 'AccessToken' = $twitterAccessToken; 'AccessTokenSecret' = $twitterAccessTokenSecret}

        if($TwitterPost.length -le 230) {
    
            $CombineTweet = ("From the Blog:",$TweetToSend.Update,$TweetToSend.URL,"#Microsoft #Azure #AzureFamily #Blog") 
   
            Write-Output "Posting Tweet: $CombineTweet" 
            
            $Parameters = @{ 'status' = $CombineTweet} 

            Invoke-TwitterRestMethod -ResourceURL 'https://api.twitter.com/1.1/statuses/update.json' -RestVerb 'POST' -Parameters $Parameters -OAuthSettings $TwitterOAuthConfig


    }