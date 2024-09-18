function Get-TopdeskBranches{
  [CmdletBinding()]
  param(
    [Parameter()][string]$fields,
    [Parameter()][string]$id,
    [Parameter()][string]$startsWith,
    [Parameter()][string]$query,
    [Parameter()][string]$clientReferenceNumber
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/branches"
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()  
  # Create a list of the query parts that we would add the to the endpoint
  $queryparts = [System.Collections.Generic.List[PSCustomObject]]@()    
  # If id is not null, then set to how we want to see
  if($PSBoundParameters.ContainsKey("id")){
    $endpoint = "$($endpoint)/id/$($id)"
  }  
  # For backwards compat, allow to send specific query items that are common
  # If startswith is sent
  if($PSBoundParameters.ContainsKey("startsWith")){
    $queryparts.add("name=sw=$($startsWith)")
  }
  # If clientReferenceNumber is sent
  if($PSBoundParameters.ContainsKey("clientReferenceNumber")){
    $queryparts.add("clientReferenceNumber=sw=$($clientReferenceNumber)")
  }   
  # If query is not null, then set to how we want to see
  if($PSBoundParameters.ContainsKey("query") -or $queryparts.count -gt 0){
    $queryparts.add($query)
    $query = ($queryparts -join ";") -replace ".{1}$"
    $uriparts.add("query=$($query)")
  }
  # If fields is not null, then set to how we want to see
  if($PSBoundParameters.ContainsKey("fields")){
    $uriparts.add("`$fields=$($fields)")
  }    
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"
  # Array to hold results from the API call
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.Count) results."
    # Load results into an array
    foreach($item in $results.Results){
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return $data
}