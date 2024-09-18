function Get-TopdeskRoles{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter()][string]$id, 
    [Parameter()][bool]$archived,
    [Parameter()][bool]$licensed,
    [Parameter()][string]$fields
  )  
  $endpoint = "/services/permissions/roles"
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "$($endpoint)/$($id)"
  }
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()  
  if ($PSBoundParameters.ContainsKey("archived")) { $uriparts.add("archived=$($archived)") } 
  if ($PSBoundParameters.ContainsKey("licensed")) { $uriparts.add("licensed=$($licensed)") } 
  if ($PSBoundParameters.ContainsKey("fields")) { $uriparts.add("fields=$($fields)") } 
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    if($results.results._embedded.item){
      $process = $results.results._embedded.item
    }
    else{
      $process = $results.results
    }
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