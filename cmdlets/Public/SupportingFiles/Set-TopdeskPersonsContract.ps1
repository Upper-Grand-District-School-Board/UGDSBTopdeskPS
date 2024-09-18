function Set-TopdeskPersonsContract {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true)][string]$id,
    [Parameter()][datetime]$hireDate,
    [Parameter()][datetime]$employmentTerminationDate,
    [Parameter()][datetime]$contractStartDate,
    [Parameter()][datetime]$contractExpiryDate,
    [Parameter()][datetime]$endProbationPeriod
  )  
  $endpoint = "/tas/api/persons/id/$($id)/contract"
  $body = @{}  
  if ($PSBoundParameters.ContainsKey("hireDate")) { $body.Add("hireDate", $hireDate) }
  if ($PSBoundParameters.ContainsKey("employmentTerminationDate")) { $body.Add("employmentTerminationDate", $employmentTerminationDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")) }
  if ($PSBoundParameters.ContainsKey("contractStartDate")) { $body.Add("contractStartDate", $contractStartDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")) }
  if ($PSBoundParameters.ContainsKey("contractExpiryDate")) { $body.Add("contractExpiryDate", $contractExpiryDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")) }
  if ($PSBoundParameters.ContainsKey("endProbationPeriod")) { $body.Add("endProbationPeriod", $endProbationPeriod.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")) }
  try {
    if($body.count -gt 0){
      $results = Get-TopdeskAPIResponse -endpoint $endpoint -Method PATCH -body ($body | ConvertTo-Json) -Verbose:$VerbosePreference
    }
  }
  catch {
    throw $_
  }  
  return $results.results   
}