<#
  .DESCRIPTION
  This will return the list of asset templates for the topdesk platform.
  .PARAMETER archived
  Whether to show archived templates. Leave out for all, or specify true/false for only archived, or only active templates, respectively.
  .PARAMETER includeNonReadable
  Whether to show templates for assets which the user doesn't have read permission for. If this parameter isn't specified the endpoint returns templates for assets which the user has read permission for.
  .PARAMETER resourceCategory
  The endpoint returns templates matching the specified category only.
  .PARAMETER searchTerm
  The endpoint returns those templates which contain the given searchTerm in their name. It's case insensitive.
  .EXAMPLE
#>
function Get-TopdeskAssetTemplates{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter()][bool]$archived,
    [Parameter()][bool]$includeNonReadable,
    [Parameter()][ValidateSet("asset","stock","bulkItem")][string]$resourceCategory,
    [Parameter()][string][ValidateNotNullOrEmpty()]$searchTerm
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/assetmgmt/templates"
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If archived is not null, then set to how we want to see
  if($PSBoundParameters.ContainsKey("archived")){
    $uriparts.add("archived=$($archived)")
  }  
  # If includeNonReadable is not null, then set to how we want to see
  if($PSBoundParameters.ContainsKey("includeNonReadable")){
    $uriparts.add("includeNonReadable=$($includeNonReadable)")
  }  
  # If resourceCategory is not null, then set to how we want to see
  if($PSBoundParameters.ContainsKey("resourceCategory")){
    $uriparts.add("resourceCategory=$($resourceCategory)")
  }   
  # If searchTerm is not null, then add to URI parts
  if($PSBoundParameters.ContainsKey("searchTerm")){
    $uriparts.add("searchTerm=$($searchTerm)")
  }
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