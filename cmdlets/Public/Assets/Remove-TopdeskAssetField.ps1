<#
  .DESCRIPTION
  
  .PARAMETER fieldId
  Id of the field
#>
function Remove-TopdeskAssetField{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$fieldid
  )
  $endpoint = "/tas/api/assetmgmt/fields/$($fieldId)"
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference -Method "Delete" | Out-Null
    Write-Verbose "Deleted asset field with id $($fieldid) from system." 
  } 
  catch{
    throw $_
  }      
}