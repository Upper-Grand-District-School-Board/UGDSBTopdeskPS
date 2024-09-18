function New-TopdeskKnowledgeItemTranslation {
  [cmdletbinding()]
  param(
    [Alias("identifier")]
    [Parameter(Mandatory = $true, ParameterSetName = 'body')]
    [Parameter(Mandatory = $true, ParameterSetName = 'Title')]
    [ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true, ParameterSetName = 'body')][PSCustomObject]$body,
    [Parameter(ParameterSetName = 'Title')][string]$language = "en-CA",
    [Parameter(Mandatory = $true, ParameterSetName = 'Title')][string]$title,
    [Parameter(ParameterSetName = 'Title')][string]$description,
    [Parameter(ParameterSetName = 'Title')][string]$content,
    [Parameter(ParameterSetName = 'Title')][string]$commentsForOperators,
    [Parameter(ParameterSetName = 'Title')][string]$keywords
  )  
  # The endpoint to get assets
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/translations"     
  if (-not $PSBoundParameters.ContainsKey("body")) {
    $body = @{
      language = $language
      content  = @{
        title                = $title
        description          = $description
        content              = $content
        commentsForOperators = $commentsForOperators
        keywords             = $keywords        
      }      
    }
  }
  try {
    $header = $global:topdeskHeader.Clone()
    $header."content-type" = "application/x.topdesk-kb-create-translation-v1+json"
    Get-TopdeskAPIResponse -endpoint $endpoint -headers $header -Method "POST" -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference -AllowInsecureRedirect
    Write-Verbose "Created knowledgeitem translation." 
  } 
  catch {
    throw $_
  }   
}