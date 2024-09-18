function New-TopdeskAssetImportUpload{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$filePath,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$fileName,
    [Parameter()][string]$TopdeskTenant
  )
  $endpoint = "/services/import-to-api-v1/api/sourceFiles?filename=$($fileName)"
  $header = $global:topdeskHeader.Clone()
  $header."Content-Type" = "application/octet-stream"
  try {
    Get-TopdeskAPIResponse -endpoint $endpoint -Method "PUT" -headers $header -filePath $filePath -Verbose:$VerbosePreference
  }
  catch{
    throw $_ 
  }
}