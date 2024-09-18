<#
  .DESCRIPTION
  
  .PARAMETER type
  Type of the linked entity
  .PARAMETER targetId
  Id of the linked entity.
  .PARAMETER assetids
  The ID of the asset
  .PARAMETER linkId
  The ID of the assignment
#>
function Remove-TopdeskAssetAssignments{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true,ParameterSetName = 'POST')][ValidateSet("branch", "location", "personGroup","person")][string]$type,
    [Parameter(Mandatory = $true,ParameterSetName = 'POST')][ValidateNotNullOrEmpty()][string]$targetId,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string[]]$assetids,
    [Parameter(Mandatory = $true,ParameterSetName = 'DELETE')][ValidateNotNullOrEmpty()][string]$linkId
  )
  $vars = @{
    Verbose = $VerbosePreference
  }
  switch($PSCmdlet.ParameterSetName){
    "POST" {
      $vars.Method = "POST"
      $vars.endpoint = "/tas/api/assetmgmt/assets/unlink/$($type)/$($targetId)"
      $vars.body = @{
        assetIds = $assetids
      } | ConvertTo-Json
    }
    "DELETE" {
      $vars.Method = "DELETE"
      $vars.endpoint = "/tas/api/assetmgmt/assets/$($assetids)/assignments/$($linkId)"
    }
  }
  try{
    $results = Get-TopdeskAPIResponse @vars
  }
  catch{
    throw $_
  }
  return $results.Results
}