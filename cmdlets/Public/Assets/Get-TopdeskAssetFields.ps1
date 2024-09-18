<#
  .DESCRIPTION
  
  .PARAMETER searchTerm
  Include fields only if their display name contains the given text fragment.
  .PARAMETER resourceCategory
  The endpoint returns assets matching the specified category only.
#>
function Get-TopdeskAssetFields{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter()][ValidateNotNullOrEmpty()][string]$searchTerm,
    [Parameter()][ValidateSet("asset", "stock", "bulkItem")][string]$resourceCategory
  )  
  $endpoint = "/tas/api/assetmgmt/fields"
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If searchTerm is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("searchTerm")) { $uriparts.add("searchTerm=$($searchTerm)") }    
  # If lastSeenName is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("resourceCategory")) { $uriparts.add("resourceCategory=$($resourceCategory)") }   
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
  # Array to hold results from the API call
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.dataSet.Count) results."
    # Load results into an array
    foreach($item in $results.Results.dataSet){
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return $data  
}