function Set-TopdeskIncidentDeescalation{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "id")][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true, ParameterSetName = "number")][ValidateNotNullOrEmpty()][string]$number,
    [Parameter()][ValidateNotNullOrEmpty()][string]$reason,
    [Parameter()][ValidateNotNullOrEmpty()][string]$reasonid    
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/deescalate"
  }
  if ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/deescalate"
  }  
  if ($PSBoundParameters.ContainsKey("reason")) {
    $body = @{"name" = $reason}
  }
  if ($PSBoundParameters.ContainsKey("reasonid")) {
    $body = @{"id" = $reasonid}
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference -Method "Put" | Out-Null
    Write-Verbose "Deescanted incident id $($number)." 
  } 
  catch{
    throw $_
  }
}