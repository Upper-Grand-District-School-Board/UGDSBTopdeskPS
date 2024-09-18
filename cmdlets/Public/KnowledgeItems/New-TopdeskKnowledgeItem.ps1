function New-TopdeskKnowledgeItem {
  [cmdletbinding()]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = 'body')][PSCustomObject]$body,
    [Parameter(ParameterSetName = 'Title')][string]$parent,
    [Parameter(ParameterSetName = 'Title')][string]$language = "en-CA",
    [Parameter(Mandatory = $true, ParameterSetName = 'Title')][string]$title,
    [Parameter(ParameterSetName = 'Title')][string]$description,
    [Parameter(ParameterSetName = 'Title')][string]$content,
    [Parameter(ParameterSetName = 'Title')][string]$commentsForOperators,
    [Parameter(ParameterSetName = 'Title')][string]$keywords,
    [Parameter(ParameterSetName = 'Title')][ValidateSet("NOT_VISIBLE", "VISIBLE", "VISIBLE_IN_PERIOD")][string]$sspVisibility = "NOT_VISIBLE",
    [Parameter(ParameterSetName = 'Title')][datetime]$sspVisibleFrom,
    [Parameter(ParameterSetName = 'Title')][datetime]$sspVisibleUntil,
    [Parameter(ParameterSetName = 'Title')][bool]$sspVisibilityFilteredOnBranches = $false,
    [Parameter(ParameterSetName = 'Title')][bool]$operatorVisibilityFilteredOnBranches = $false,
    [Parameter(ParameterSetName = 'Title')][bool]$openKnowledgeItem = $false,
    [Parameter(ParameterSetName = 'Title')][string]$status,
    [Parameter(ParameterSetName = 'Title')][string]$manager,
    [Parameter(ParameterSetName = 'Title')][string]$externalLinkid,
    [Parameter(ParameterSetName = 'Title')][string]$externalLinktype,
    [Parameter(ParameterSetName = 'Title')][datetime]$externalLinkdate
  )  
  # The endpoint to get assets
  $endpoint = "/services/knowledge-base-v1/knowledgeItems"  
  if (-not $PSBoundParameters.ContainsKey("body")) {
    $body = @{
      parent       = @{
        number = $parent
      }
      translation  = @{
        language = $language
        content  = @{
          title                = $title
          description          = $description
          content              = $content
          commentsForOperators = $commentsForOperators
          keywords             = $keywords        
        }
      }
      visibility   = @{
        sspVisibility                        = $sspVisibility
        sspVisibleFrom                       = $sspVisibleFrom
        sspVisibleUntil                      = $sspVisibleUntil
        sspVisibilityFilteredOnBranches      = $sspVisibilityFilteredOnBranches
        operatorVisibilityFilteredOnBranches = $operatorVisibilityFilteredOnBranches
        openKnowledgeItem                    = $openKnowledgeItem
      }
      externalLink = @{
        id   = $externalLinkid
        type = $externalLinktype
        date = $externalLinkdate
      }
    }
    if ($PSBoundParameters.ContainsKey("status")) {
      $body.Add("status", @{id = $status}) | Out-Null
    }
    if ($PSBoundParameters.ContainsKey("manager")) {
      $body.Add("manager",@{id = $manager}) | Out-Null
    }
  }
  try {
    $header = $global:topdeskHeader.Clone()
    $header."content-type" = "application/x.topdesk-kb-create-ki-v1+json"
    Get-TopdeskAPIResponse -endpoint $endpoint -headers $header -Method "POST" -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference -AllowInsecureRedirect
    Write-Verbose "Created knowledgeitem." 
  } 
  catch {
    throw $_
  }   
}