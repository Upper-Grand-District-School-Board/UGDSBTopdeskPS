function Get-TopdeskPersonsCount{
  [cmdletbinding()]
  [OutputType([int])]
  param(
    [Parameter()][string]$query
  ) 
  # The endpoint to get assets
  $endpoint = "/tas/api/persons/count"
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()   
  if ($PSBoundParameters.ContainsKey("query")) { $uriparts.add("query=$($query)") }   
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    # Load results into an array
    foreach($item in $results.Results){
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return  $results.Results.numberOfPersons   
}