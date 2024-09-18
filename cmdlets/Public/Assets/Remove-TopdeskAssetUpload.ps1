function Remove-TopdeskAssetUpload{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$uploadId
  )
  $endpoint = "/tas/api/assetmgmt/uploads/$($uploadId)"
  try{
    Get-TopdeskAPIResponse -endpoint $endpoint -Method "Delete" -Verbose:$VerbosePreference
  }
  catch{
    throw $_
  }
}