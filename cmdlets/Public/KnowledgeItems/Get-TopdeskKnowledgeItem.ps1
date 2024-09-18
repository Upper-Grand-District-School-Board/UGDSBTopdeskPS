function Get-TopdeskKnowledgeItem{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter()][string]$id, 
    [Alias("page_size")][Parameter()][ValidateRange(1, 1000)][int]$pageSize = 100,
    [Alias("start")][Parameter()][int]$pageStart = 0,   
    [Parameter()][string]$fields, 
    [Parameter()][string]$query,
    [Parameter()][string]$language = "en-CA",
    [Parameter()][switch]$all
  )
  # The endpoint to get assets
  $endpoint = "/services/knowledge-base-v1/knowledgeItems"
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)"
  }
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If pageStart is not null, then add to URI parts
  $uriparts.add("start=$($pageStart)")
  # If pageSize is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("pageSize")) { $uriparts.add("page_size=$($pageSize)") }
  # If fields is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("fields")) { $uriparts.add("fields=$($fields)") } 
  # If query is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("query")) { $uriparts.add("query=$($query)") }     
  # If fields is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("language")) { $uriparts.add("language=$($language)") }   
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
  try {
    # Array to hold results from the API call
    $data = [System.Collections.Generic.List[PSObject]]@()
    $uri = $endpoint
    do {
      # Execute API Call
      $results = Get-TopdeskAPIResponse -endpoint $uri -Verbose:$VerbosePreference
      if($results.results.item.count -gt 0){
        $process = $results.results.item
      }
      else{
        $process = $results.results
      }
      # Load results into an array
      foreach ($item in $process) {
        $data.Add($item) | Out-Null
      }
      $pagestart += $pageSize
      Write-Verbose "Returned $($results.Results.item.Count) results. Current result set is $($data.Count) items."      
      $uri = $uri -replace "start=\d*", "start=$($pagestart)"
    }
    while ($all.IsPresent -and $results.StatusCode -eq 206)
  }
  catch {
    throw $_
  }  
  return $data
}