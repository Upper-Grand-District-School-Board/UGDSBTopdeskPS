function Get-TopdeskTimeRegistrations{
  [CmdletBinding(DefaultParameterSetName = "All")]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "id")][string][ValidateNotNullOrEmpty()]$id,
    [Alias("start")][Parameter()][int][ValidateNotNullOrEmpty()]$pageStart = 0,
    [Alias("page_size")][Parameter()][int][ValidateRange(1, 10000)]$pageSize = 100,
    [Parameter()][string][ValidateNotNullOrEmpty()]$query,
    [Parameter()][string][ValidateNotNullOrEmpty()]$fields,
    [Parameter()][switch]$all
  )
  $endpoint = "/tas/api/incidents/timeregistrations"
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "$($endpoint)/$($id)"
  }  
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If pageSize is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("pageSize")) { $uriparts.add("pageSize=$($pageSize)") } 
  # If sort is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("sort")) { $uriparts.add("sort=$($sort)") } 
  # If query is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("query")) { $uriparts.add("query=$($query)") } 
  # If fields is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("fields")) { $uriparts.add("fields=$($fields)") } 
  # Add page start
  $uriparts.add("pageStart=$($pageStart)")
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
      foreach ($item in $results.Results.Results) {
        $data.Add($item) | Out-Null
      }
      $pagestart += $pageSize
      Write-Verbose "Returned $($results.Results.Results.Count) results. Current result set is $($data.Count) items."      
      $uri = $results.Results.next -replace $global:topdeskAPIEndpoint
    }
    while ($all.IsPresent -and $null -ne $results.Results.next)
  }
  catch {
    throw $_
  }  
  return $data
}