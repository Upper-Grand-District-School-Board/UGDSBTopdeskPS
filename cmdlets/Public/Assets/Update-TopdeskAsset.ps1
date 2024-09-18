function Update-TopdeskAsset{
  [CmdletBinding()]
  param(
    [Alias("unid")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$assetId,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][hashtable]$update
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/assetmgmt/assets/$($assetId)"  
  try{
    Get-TopdeskAPIResponse -endpoint $endpoint -Method "POST" -body ($update | ConvertTo-JSON) -Verbose:$VerbosePreference | Out-Null
    Write-Verbose "Updating asset with id $($assetId) from system." 
  } 
  catch{
    throw $_
  }  
}