function Set-TopdeskKnowledgeItemArchive{
  [CmdletBinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/archive"
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference -Method "POST" | Out-Null
    Write-Verbose "Archived KI id $($id)." 
  } 
  catch{
    throw $_
  }    
}