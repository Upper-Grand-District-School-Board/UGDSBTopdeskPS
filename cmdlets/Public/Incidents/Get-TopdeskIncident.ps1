<#
  .DESCRIPTION
  
  .PARAMETER id
  The ID of the incident
  .PARAMETER number
  The incident number
  .PARAMETER pageStart
  The offset to start at. The default is 0.
  .PARAMETER pageSize
  How many incidents should be returned max. Default is 10.
  .PARAMETER sort
  The sort order of the returned incidents. Incidents can be ordered by most of the fields. But for best performance one should order by one of the following fields: callDate, creationDate, modificationDate, targetDate, closedDate or id. It's faster to order by 1 field only. To specify if the order should be ascending or descending, append ":asc" or ":desc" to the field name. Multiple columns can be specified by comma-joining the orderings. Example: sort=tragetDate:asc,creationDate:desc. Fields not allowed for sorting are: externalLinks, escalationStatus, action, attachments, partialIncidents, partialIncidents.link
  .PARAMETER query
  A FIQL string to select which incidents should be returned. (See https://developers.topdesk.com/tutorial.html#query)
  .PARAMETER fields
  A comma-separated list of which fields should be returned. By default all fields will be returned. (slow)
  .PARAMETER dateFormat
  Format of date fields in json. When set to iso8601 dates will be sent in the form of '2020-10-01T14:10:00Z'. Otherwise old date format will be used: '2020-10-01T14:10:00.000+0000'
  .PARAMETER alltypes
  when present or when present and set to true will make all incident to be returned. Including partials and archived. This overrides the default behaviour when only firstLine and secondLine incidents are returned by default. This can be used in combinations with query parameter to narrow down the requited statuses.
  .PARAMETER all
  when present will make all incidents to be returned, looping over return of code 206 partial content

#>
function Get-TopdeskIncident {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter()][string][ValidateNotNullOrEmpty()]$id,
    [Parameter()][string][ValidateNotNullOrEmpty()]$number,
    [Parameter()][int][ValidateNotNullOrEmpty()]$pageStart = 0,
    [Parameter()][int][ValidateRange(1, 10000)]$pageSize = 10,
    [Parameter()][string][ValidateNotNullOrEmpty()]$sort,
    [Parameter()][string][ValidateNotNullOrEmpty()]$query,
    [Parameter()][string][ValidateNotNullOrEmpty()]$fields,
    [Parameter()][switch]$dateFormat,
    [Parameter()][switch]$alltypes,
    [Parameter()][switch]$all
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/incidents"
  # Check if we are getting a specific incident or query against all incidents
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)"
  }
  elseif ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)"
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
  # If dateFormat is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("dateFormat")) { $uriparts.add("dateFormat=iso8601") }
  # If alltypes is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("alltypes")) { $uriparts.add("all=$($alltypes.IsPresent)") }  
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
      foreach ($item in $results.Results) {
        $data.Add($item) | Out-Null
      }
      $pagestart += $pageSize
      Write-Verbose "Returned $($results.Results.Count) results. Current result set is $($data.Count) items."      
      $uri = $uri -replace "pageStart=\d*", "pageStart=$($pagestart)"
    }
    while ($all.IsPresent -and $results.StatusCode -eq 206)
  }
  catch {
    throw $_
  }  
  return $data
}