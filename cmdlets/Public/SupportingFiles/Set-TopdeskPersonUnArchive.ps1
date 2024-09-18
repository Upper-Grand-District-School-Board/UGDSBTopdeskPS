function Set-TopdeskPersonUnArchive {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true)][string]$id
  )
  $endpoint = "/tas/api/persons/id/$($id)/unarchive"
  try {
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Method PUT -Verbose:$VerbosePreference
  }
  catch {
    throw $_
  }  
  return $results.results  
}