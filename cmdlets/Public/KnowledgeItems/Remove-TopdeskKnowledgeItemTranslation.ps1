function Remove-TopdeskKnowledgeItemTranslation{
  [cmdletbinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true)][string]$language
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/translations/$($language)"
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference -Method "Delete" | Out-Null
    Write-Verbose "Deleted translation entry with language $($language)." 
  } 
  catch{
    throw $_
  }   
}