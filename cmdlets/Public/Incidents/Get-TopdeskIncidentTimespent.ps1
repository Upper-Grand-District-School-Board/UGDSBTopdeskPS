function Get-TopdeskIncidentTimespent{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "id")][string][ValidateNotNullOrEmpty()]$id,
    [Parameter(Mandatory = $true, ParameterSetName = "number")][string][ValidateNotNullOrEmpty()]$number   
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/timespent"
  }
  elseif ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/timespent"
  }
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    $process = $results.results | Where-Object {$_ -ne ""}
    Write-Verbose "Returned $($process.Count) results."
    # Load results into an array
    foreach($item in $process){
      $data.Add($item) | Out-Null
    } 
  } 
  catch{
    throw $_
  }  
  return $data
}