function Set-TopdeskIncidentArchive{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "id")][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true, ParameterSetName = "number")][ValidateNotNullOrEmpty()][string]$number,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$reason
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/archive"
  }
  if ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/archive"
  } 
  $body = @{
    "name" = $reason
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference -Method "Put" | Out-Null
    Write-Verbose "Archived incident id $($number)." 
  } 
  catch{
    throw $_
  }   
}