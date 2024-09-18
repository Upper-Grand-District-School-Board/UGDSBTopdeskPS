function New-TopdeskKnowledgeItemStatues{
  [cmdletbinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$name
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItemStatuses"
  $body = @{
    name = $name
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference -Method "POST" | Out-Null
  } 
  catch{
    throw $_
  }   
}