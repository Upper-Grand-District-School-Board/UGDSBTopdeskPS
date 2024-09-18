<#
  .DESCRIPTION
  
  .PARAMETER fieldId
  Id of the field
  .PARAMETER resourceCategory
  If possible functionalities should be included into the response
#>
function Get-TopdeskAssetFieldDefinition{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true)][string][ValidateNotNullOrEmpty()]$fieldId,
    [Parameter()][switch]$includeFunctionalities
  )  
  $endpoint = "/tas/api/assetmgmt/fields/$($fieldId)"
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()  
  # If includeFunctionalities is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("includeFunctionalities")) { $uriparts.add("includeFunctionalities=$($includeFunctionalities)") }  
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
  # Array to hold results from the API call
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.Count) results."
    # Load results into an array
    foreach($item in $results.Results){
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return $data    
}