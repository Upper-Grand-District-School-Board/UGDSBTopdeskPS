function Get-TopdeskPersonsAvatar{
  [cmdletbinding()]
  param(
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id
  )
  $endpoint = "/tas/api/persons/id/$($id)/avatar"
  # Execute API Call
  $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
  return $results.results
}