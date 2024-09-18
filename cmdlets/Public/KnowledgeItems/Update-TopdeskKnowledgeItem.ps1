function Update-TopdeskKnowledgeItem {
  [cmdletbinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter()]$body,
    [Parameter()][string]$parent,
    [Parameter()][ValidateSet("NOT_VISIBLE", "VISIBLE", "VISIBLE_IN_PERIOD")][string]$sspVisibility = "NOT_VISIBLE",
    [Parameter()][datetime]$sspVisibleFrom,
    [Parameter()][datetime]$sspVisibleUntil,
    [Parameter()][bool]$sspVisibilityFilteredOnBranches = $false,
    [Parameter()][bool]$operatorVisibilityFilteredOnBranches = $false,
    [Parameter()][bool]$openKnowledgeItem,
    [Parameter()][string]$status,
    [Parameter()][string]$manager,
    [Parameter()][string]$externalLinkid,
    [Parameter()][string]$externalLinktype,
    [Parameter()][datetime]$externalLinkdate
  )
  # The endpoint to get assets
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)"
  if (-not $PSBoundParameters.ContainsKey("body")) {
    # Create blank body
    $body = @{}
    # Add the parent if it exists
    if ($PSBoundParameters.ContainsKey("parent")) {
      $body.Add("parent", @{number = $parent })
    }
    # Create blank visibility hash to add if required
    $visibility = @{
      operatorVisibilityFilteredOnBranches = $operatorVisibilityFilteredOnBranches
      sspVisibilityFilteredOnBranches      = $sspVisibilityFilteredOnBranches    
      sspVisibility                        = $sspVisibility  
    }
    if ($PSBoundParameters.ContainsKey("sspVisibleFrom")) {
      $visibility.Add("sspVisibleFrom", $sspVisibleFrom.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))
    }
    if ($PSBoundParameters.ContainsKey("sspVisibleUntil")) {
      $visibility.Add("sspVisibleUntil", $sspVisibleUntil.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))
    }  
    if ($PSBoundParameters.ContainsKey("openKnowledgeItem")) {
      $visibility.Add("openKnowledgeItem", $openKnowledgeItem)
    }
    if ($visibility.count -ne 0) {
      $body.Add("visibility", $visibility)
    }
    if ($PSBoundParameters.ContainsKey("status")) {
      $body.Add("status", @{id = $status })
    }
    if ($PSBoundParameters.ContainsKey("manager")) {
      $body.Add("manager", @{id = $manager })
    }  
    # Create blank externalLink hash to add if required
    $externalLink = @{}
    if ($PSBoundParameters.ContainsKey("externalLinkid")) {
      $externalLink.Add("id", $externalLinkid)
    }
    if ($PSBoundParameters.ContainsKey("externalLinktype")) {
      $externalLink.Add("type", $externalLinktype)
    }   
    if ($PSBoundParameters.ContainsKey("externalLinkdate")) {
      $externalLink.Add("date", $externalLinkdate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))
    }    
    if ($externalLink.count -ne 0) {
      $body.Add("externalLink", $externalLink)
    }  
  }
  try {
    Get-TopdeskAPIResponse -endpoint $endpoint -Method "POST" -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference | Out-Null
    Write-Verbose "Updating knowledgeitem with id $($id) from system." 
  } 
  catch {
    throw $_
  }   
}