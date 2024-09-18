function Get-TopdeskPersonsPrivateDetails{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter(Mandatory = $true)][string]$id
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/persons/id/$($id)/privateDetails"
  try {
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
  }
  catch {
    throw $_
  }  
  return $results.results
}