<#
  .DESCRIPTION
  
  .PARAMETER assetId
  The ID of the asset
  .PARAMETER includeInherited
  Include inherited assignments in the response. Inherited assignments do not have a linkId, but have an inheritanceParentId (the id of the asset it is inherited from).
  .PARAMETER limit
  The maximum number of assignments to return in one response. Must be a decimal number greater than 0.fs
#>
function Get-TopdeskAssetAssignments{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$assetId,
    [Parameter()][switch]$includeInherited,
    [Parameter()][ValidateNotNullOrEmpty()][string]$limit
  )
  $endpoint = "/tas/api/assetmgmt/assets/$($assetId)/assignments"
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If includeInherited is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("includeInherited")) { $uriparts.add("includeInherited=$($includeInherited.IsPresent)") }   
  # If limit is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("limit")) { $uriparts.add("limit=$($limit)") }    
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"      
  # Array to hold results from the API call
  $locations = [System.Collections.Generic.List[PSObject]]@()
  $persons = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.Count) results."
    # Load results into an array
    foreach($item in $results.Results.locations){
      $locations.add($item) | Out-Null
    }
    foreach($item in $results.Results.persons){
      $persons.add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return [PSCustomObject]@{
    Locations = $locations
    Persons = $persons
  } 
}