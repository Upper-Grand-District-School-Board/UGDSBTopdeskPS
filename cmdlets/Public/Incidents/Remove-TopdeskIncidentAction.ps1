function Remove-TopdeskIncidentAction{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "id")][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true, ParameterSetName = "number")][ValidateNotNullOrEmpty()][string]$number,
    [Parameter(Mandatory = $true)][string]$actionid  
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/actions/$($actionid)"
  }
  if ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/actions/$($actionid)"
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference -Method "Delete" | Out-Null
    Write-Verbose "Deleted action entry with id $($actionid)." 
  } 
  catch{
    throw $_
  }    
}