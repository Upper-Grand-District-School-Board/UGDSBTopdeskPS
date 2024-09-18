function Add-TopdeskIncidentTimespent{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "id")][string][ValidateNotNullOrEmpty()]$id,
    [Parameter(Mandatory = $true, ParameterSetName = "number")][string][ValidateNotNullOrEmpty()]$number,
    [Parameter()][int]$timeSpent = 0,
    [Parameter()][string]$notes,
    [Parameter()][datetime]$entryDate = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"),
    [Parameter()][string]$operator,
    [Parameter()][string]$operatorGroup,
    [Parameter()][string]$reason
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/timespent"
  }
  elseif ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/timespent"
  }
  $body = @{
    timeSpent = $timeSpent
    notes = $notes
    entryDate = $entryDate
  }
  if ($PSBoundParameters.ContainsKey("operator")) {
    $body.Add("operator",@{id = $operator})
  }
  if ($PSBoundParameters.ContainsKey("operatorGroup")) {
    $body.Add("operatorGroup",@{id = $operatorGroup})
  }
  if ($PSBoundParameters.ContainsKey("reason")) {
    $body.Add("reason",@{id = $reason})
  }
  try{
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Method "POST" -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference | Out-Null
  }
  catch{
    throw $_
  }
  return $results.Results
}