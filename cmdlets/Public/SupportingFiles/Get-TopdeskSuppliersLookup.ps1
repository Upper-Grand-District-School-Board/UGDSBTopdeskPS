function Get-TopdeskSuppliersLookup{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter()][string]$id,
    [Parameter()][ValidateRange(1, 10000)][int]$top = 1000,
    [Parameter()][string]$name,
    [Parameter()][bool]$archived,
    [Parameter()][switch]$all
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/suppliers/lookup"
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "$($endpoint)/$($id)"
  }   
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  if ($PSBoundParameters.ContainsKey("top")) { $uriparts.add("`$top=$($top)") } 
  if ($PSBoundParameters.ContainsKey("name")) { $uriparts.add("`$name=$($name)") } 
  if ($PSBoundParameters.ContainsKey("archived")) { $uriparts.add("archived=$($archived)") } 
  if ($PSBoundParameters.ContainsKey("all")) { $uriparts.add("`$all=$($all.IsPresent)") } 
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    if($results.results.results.count -gt 0){
      $process = $results.results.results
    }
    else{
      $process = $results.results
    }    
    Write-Verbose "Returned $($process.count) results."
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