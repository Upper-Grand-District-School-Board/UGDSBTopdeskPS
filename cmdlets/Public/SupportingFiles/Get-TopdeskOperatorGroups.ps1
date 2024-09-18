function Get-TopdeskOperatorGroups{
  [CmdletBinding()]
  [Alias("Get-TopdeskOperatorGroup")]
  param(
    [Parameter()][ValidateNotNullOrEmpty()][string]$id,
    [Parameter()][int]$start = 0,
    [Parameter()][ValidateRange(1, 100)][int]$page_size = 10,
    [Parameter()][ValidateNotNullOrEmpty()][string]$query,
    [Parameter()][ValidateNotNullOrEmpty()][string]$fields,
    [Parameter()][switch]$all
  )
  $endpoint = "/tas/api/operatorgroups"
  if ($PSBoundParameters.ContainsKey("id")){
    $endpoint = "/tas/api/operatorgroups/id/$($id)"
  }
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()    
  # If pageStart is not null, then add to URI parts
  $uriparts.add("start=$($start)")  
  # If pageSize is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("page_size")) { $uriparts.add("page_size=$($page_size)") }  
  # If query is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("query")) { $uriparts.add("query=$($query)") }   
  # If fields is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("fields")) { $uriparts.add("fields=$($fields)") }   
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
  try {
    # Array to hold results from the API call
    $data = [System.Collections.Generic.List[PSObject]]@()
    $uri = $endpoint
    do {
      # Execute API Call
      $results = Get-TopdeskAPIResponse -endpoint $uri -Verbose:$VerbosePreference
      # Load results into an array
      foreach ($item in $results.results) {
        $data.Add($item) | Out-Null
      }
      $start += $page_size
      Write-Verbose "Returned $($results.Results.Count) results. Current result set is $($data.Count) items."      
      $uri = $uri -replace "start=\d*", "start=$($start)"
    }
    while ($all.IsPresent -and $results.StatusCode -eq 206)
  }
  catch {
    throw $_
  }  
  return $data 
}