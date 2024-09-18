function Set-TopdeskKnowledgeItemStatusArchive{
  [cmdletbinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItemStatuses/$($id)/archive"
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference -Method "POST" | Out-Null
  } 
  catch{
    throw $_
  } 
}