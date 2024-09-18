function Remove-TopdeskKnowledgeItemImage {
  [cmdletbinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$imagename
  ) 
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/images/$($imagename)"
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference -Method "Delete" | Out-Null
    Write-Verbose "Deleted knowledge item image$($imagename) from KI $($id)." 
  } 
  catch{
    throw $_
  } 
}