function Get-TopdeskIncidentRequests{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "id")][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true, ParameterSetName = "number")][ValidateNotNullOrEmpty()][string]$number,
    [Parameter()][ValidateNotNullOrEmpty()][string]$requestid,
    [Parameter()][int][ValidateNotNullOrEmpty()]$Start = 0,
    [Parameter()][int][ValidateRange(1, 100)]$page_Size = 10, 
    [Parameter()][switch]$inlineimages,
    [Parameter()][switch]$non_api_attachment_urls,    
    [Parameter()][switch]$all
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/requests"
  }
  if ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/requests"
  }
  if ($PSBoundParameters.ContainsKey("requestid")) {
    $endpoint = "$($endpoint)/$($requestid)"
  }
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If pageSize is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("pageSize")) { $uriparts.add("pageSize=$($page_Size)") } 
  # If sort is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("inlineimages")) { $uriparts.add("inlineimages=$($inlineimages.IsPresent)") } 
  # If query is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("non_api_attachment_urls")) { $uriparts.add("non_api_attachment_urls=$($non_api_attachment_urls.IsPresent)") } 
  # Add page start
  $uriparts.add("start=$($start)")
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