function Remove-TopdeskIncidentRequest{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "id")][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true, ParameterSetName = "number")][ValidateNotNullOrEmpty()][string]$number,
    [Parameter(Mandatory = $true)][string]$requestid  
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/requests/$($requestid)"
  }
  if ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/requests/$($requestid)"
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference -Method "Delete" | Out-Null
    Write-Verbose "Deleted action entry with id $($requestid)." 
  } 
  catch{
    throw $_
  }    
}