function Update-TopdeskKnowledgeItemStatues{
  [cmdletbinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$name
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItemStatuses/$($id)"
  $body = @{
    name = $name
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference -Method "PATCH" | Out-Null
  } 
  catch{
    throw $_
  }     
}