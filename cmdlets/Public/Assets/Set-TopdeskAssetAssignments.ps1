<#
  .DESCRIPTION
  
  .PARAMETER assetids
  is an asset, stock or bulk item ID array. Multiple values of the array is supported
  .PARAMETER linkType
  is the type of the target card - branch, location for assets, stocks and bulk items while person, personGroup is only for assets
  .PARAMETER linkToId
  is the ID of the target card
  .PARAMETER branchId
  is the parent branch ID of the location.
#>
function Set-TopdeskAssetAssignments{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  [Alias("Add-TopdeskAssetAssignment")]
  param(
    [Alias("assetid")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string[]]$assetids,
    [Parameter()][ValidateSet("branch", "location", "personGroup","person")][string]$linkType = "branch",
    [Alias("locationID")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$linkToId,
    [Parameter()][ValidateNotNullOrEmpty()][string]$branchId
  )
  $vars = @{
    Method = "PUT"
    Verbose = $VerbosePreference
  }
  $body = @{
    linkType = $linkType
    linkToId = $linktoid    
  }
  if($PSBoundParameters.ContainsKey("branchId")){
    $body.branchId = $branchId
  }  
  if($assetids.count -gt 1){
    $vars.endpoint = "/tas/api/assetmgmt/assets/assignments"
    $body.assetIds = $assetids
  }
  else{
    $vars.endpoint = "/tas/api/assetmgmt/assets/$($assetids)/assignments"
  }
  $vars.body = $body | ConvertTo-Json
  try{
    $results = Get-TopdeskAPIResponse @vars
  }
  catch{
    throw $_
  }
  return $results.Results
}