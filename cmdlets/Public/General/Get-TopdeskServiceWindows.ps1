function Get-TopdeskServiceWindows{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter()][ValidateNotNullOrEmpty()][string]$id,
    [Parameter()][int][ValidateRange(1, 10000)]$top = 1000, 
    [Parameter()][string][ValidateNotNullOrEmpty()]$name,
    [Parameter()][switch]$archived
  )  
  $endpoint = "/tas/api/serviceWindow/lookup/"
  if($PSBoundParameters.ContainsKey("id")){
    $endpoint = "$($endpoint)$($id)"
  }   
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  if($PSBoundParameters.ContainsKey("top")){
    $uriparts.add("`$top=$($top)")
  }      
  if($PSBoundParameters.ContainsKey("name")){
    $uriparts.add("name=$($name)")
  }
  if($PSBoundParameters.ContainsKey("archived")){
    $uriparts.add("archived=$($archived.IsPresent)")
  }
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"
  # Array to hold results from the API call
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    if($results.Results.Results.count -gt 0){
      $process = $results.Results.Results
    }
    else{
      $process = $results.Results
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
