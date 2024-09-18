function Get-TopdeskProductVersion{
  [CmdletBinding()]
  param(  
  )
  $endpoint = "/tas/api/productVersion"  
  $data = [System.Collections.Generic.List[PSObject]]@()
  try {
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.Count) results."
    # Load results into an array
    foreach ($item in $results.Results) {
      $data.Add($item) | Out-Null
    }    
  } 
  catch {
    throw $_
  }   
  return $data       
}