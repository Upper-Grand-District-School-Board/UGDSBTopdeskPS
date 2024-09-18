function Get-TopdeskOperatorChanges{
  [CmdletBinding()]
  [Alias("Get-TopDeskChangeRequest")]
  param(
    [Parameter()][string]$id,
    [Parameter()][string]$query,
    [Parameter()][ValidateSet("id","creationDate","simple.closedDate","simple.plannedImplementationDate","simple.plannedStartDate","phases.rfc.plannedEndDate","phases.progress.plannedEndDate","phases.evaluation.plannedEndDate")][string]$sort,
    [Parameter()][ValidateSet("asc","desc")][string]$direction = "asc",
    [Parameter()][ValidateRange(1, 5000)][int]$pageSize = 1000,
    [Parameter()][int]$pageStart = 0,
    [Parameter()][string]$fields,
    [Parameter()][switch]$all
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/operatorChanges"
  # Check if we are getting a specific incident or query against all incidents
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/operatorChanges/$($id)"
  }
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If pageStart is not null, then add to URI parts
  $uriparts.add("pageStart=$($pageStart)")
  # If pageSize is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("pageSize")) { $uriparts.add("pageSize=$($pageSize)") }  
  # If query is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("query")) { $uriparts.add("query=$($query)") }   
  # If sort is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("sort")) { $uriparts.add("sort=$($sort):$($direction)") } 
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
      if($results.results.results.count -eq 0){
        $process = $results.results
      }
      else{
        $process = $results.results.results
      }
      # Load results into an array
      foreach ($item in $process) {
        $data.Add($item) | Out-Null
      }
      $pagestart += $pageSize
      Write-Verbose "Returned $($results.Results.Results.Count) results. Current result set is $($data.Count) items."      
      $uri = $uri -replace "pageStart=\d*", "pageStart=$($pagestart)"
    }
    while ($all.IsPresent -and $results.StatusCode -eq 206)
  }
  catch {
    throw $_
  }  
  return $data
}