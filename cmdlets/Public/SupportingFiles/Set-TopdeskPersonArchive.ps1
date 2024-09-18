function Set-TopdeskPersonArchive{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter(Mandatory = $true)][string]$id,
    [Parameter()][string]$reason_id
  )
  $endpoint = "/tas/api/persons/id/$($id)/archive"
  $body = @{}
  if ($PSBoundParameters.ContainsKey("reason_id")) { 
    $body.Add("id",$reason_id)
  } 
  try {
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Method PUT -body ($body | ConvertTo-Json) -Verbose:$VerbosePreference
  }
  catch {
    throw $_
  }  
  return $results.results  
}