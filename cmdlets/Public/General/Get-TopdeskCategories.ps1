function Get-TopdeskCategories{
  [CmdletBinding()]
  param( 
    [Parameter()][ValidateNotNullOrEmpty()][string]$fields, 
    [Parameter()][ValidateNotNullOrEmpty()][string]$query, 
    [Parameter()][ValidateNotNullOrEmpty()][string]$sort, 
    [Parameter()][switch]$pretty 
  )
  $endpoint = "/tas/api/categories"  
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  if($PSBoundParameters.ContainsKey("fields")){
    $uriparts.add("fields=$($fields)")
  }   
  if($PSBoundParameters.ContainsKey("query")){
    $uriparts.add("query=$($query)")
  }  
  if($PSBoundParameters.ContainsKey("sort")){
    $uriparts.add("sort=$($sort)")
  }  
  if($PSBoundParameters.ContainsKey("pretty")){
    $uriparts.add("pretty=$($pretty.IsPresent)")
  }     
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"
  # Array to hold results from the API call
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.results.item.count) results."
    # Load results into an array
    foreach($item in $results.results.item){
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return $data             
}