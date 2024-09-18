function Get-TopdeskSupplierContacts{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter()][string]$id,
    [Parameter()][ValidateRange(1, 10000)][int]$page_size = 1000,
    [Parameter()][string]$query
  )  
  # The endpoint to get assets
  $endpoint = "/tas/api/supplierContacts"
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "$($endpoint)/$($id)"
  }  
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@() 
  $uriparts.add("page_size=$($pageSize)")  
  if ($PSBoundParameters.ContainsKey("query")) { $uriparts.add("query=$($query)") }
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