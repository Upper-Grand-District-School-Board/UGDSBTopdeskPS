function Remove-TopdeskKnowledgeItemBranchesLink{
  [cmdletbinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$branchid
  )
  # The endpoint to get assets
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/branches/unlink"
  $body = @{
    "id" = $branchid
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($body | ConvertTo-Json) -Verbose:$VerbosePreference -Method "post" | Out-Null
  } 
  catch{
    throw $_
  }
}