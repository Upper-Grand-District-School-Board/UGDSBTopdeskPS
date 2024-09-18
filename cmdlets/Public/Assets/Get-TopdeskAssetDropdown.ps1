<#
  .DESCRIPTION
  
  .PARAMETER dropdownId
  The template ID or field key of the dropdown whose options to return.
  .PARAMETER includeArchived
  Whether to include archived dropdown options in the response. By default, only active dropdown options are returned.
#>
function Get-TopdeskAssetDropdown {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Alias("dropdownName")][Parameter(Mandatory = $true)][string]$dropdownId,
    [Parameter()][switch]$includeArchived
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/assetmgmt/dropdowns/$($dropdownId)?field=name&includeArchived=$($includeArchived.IsPresent)"
  # Array to hold results from the API call
  $data = [System.Collections.Generic.List[PSObject]]@()  
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.Results.count) results."
    # Load results into an array
    foreach($item in $results.Results.Results){
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }
  return $data
}