function Get-TopdeskIncidentSLAS{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter()][int][ValidateRange(1, 10000)]$pageSize = 10,
    [Parameter()][string][ValidateNotNullOrEmpty()]$incident,
    [Parameter()][string][ValidateNotNullOrEmpty()]$contract,
    [Parameter()][string][ValidateNotNullOrEmpty()]$person,
    [Parameter()][string][ValidateNotNullOrEmpty()]$service,
    [Parameter()][string][ValidateNotNullOrEmpty()]$branch,
    [Parameter()][string][ValidateNotNullOrEmpty()]$budgetHolder,
    [Parameter()][string][ValidateNotNullOrEmpty()]$department,
    [Parameter()][string][ValidateNotNullOrEmpty()]$branchExtraA,
    [Parameter()][string][ValidateNotNullOrEmpty()]$branchExtraB,
    [Parameter()][datetime][ValidateNotNullOrEmpty()]$contractDate,
    [Parameter()][string][ValidateNotNullOrEmpty()]$callType,
    [Parameter()][string][ValidateNotNullOrEmpty()]$category,
    [Parameter()][string][ValidateNotNullOrEmpty()]$subcategory,
    [Parameter()][string][ValidateNotNullOrEmpty()]$asset
  )
  $endpoint = "/tas/api/incidents/slas"
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  $uriparts.add("pageSize=$($pageSize)")
  # If incident is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("incident")) { $uriparts.add("incident=$($incident)") } 
  # If contract is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("contract")) { $uriparts.add("contract=$($contract)") } 
  # If person is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("person")) { $uriparts.add("person=$($person)") } 
  # If service is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("service")) { $uriparts.add("service=$($service)") } 
  # If branch is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("branch")) { $uriparts.add("sort=$($branch)") } 
  # If budgetHolder is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("budgetHolder")) { $uriparts.add("budgetHolder=$($budgetHolder)") } 
  # If department is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("department")) { $uriparts.add("department=$($department)") } 
  # If branchExtraA is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("branchExtraA")) { $uriparts.add("branchExtraA=$($branchExtraA)") }      
  # If branchExtraB is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("branchExtraB")) { $uriparts.add("branchExtraB=$($branchExtraB)") }  
  # If contractDate is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("contractDate")) { $uriparts.add("contractDate=$($contractDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))") }  
  # If callType is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("callType")) { $uriparts.add("callType=$($callType)") }  
  # If category is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("category")) { $uriparts.add("category=$($category)") }  
  # If subcategory is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("subcategory")) { $uriparts.add("subcategory=$($subcategory)") }  
  # If asset is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("asset")) { $uriparts.add("asset=$($asset)") }
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.results.Count) results."
    # Load results into an array
    foreach($item in $results.Results.results){
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return $data   
}