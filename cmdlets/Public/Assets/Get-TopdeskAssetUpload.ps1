<#
  .DESCRIPTION
  This will get a list of all the attachments that are associated with an asset, if the downloadpath is passed, it will also download the files.
  .PARAMETER assetId
  The ID of the asset, which contains the files. This is required
  .PARAMETER downloadPath
  The folder where we will save the files.
#>
function Get-TopdeskAssetUpload {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$assetId,
    [Parameter()][ValidateNotNullOrEmpty()][string]$downloadPath
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/assetmgmt/uploads?assetId=$($assetid)"
  try {
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    if ($PSBoundParameters.ContainsKey("downloadPath")) {
      foreach($file in $results.Results.dataset){
        $weburl = "$($file.url -replace "/tas/api/")"
        $filename = Join-Path $downloadPath -ChildPath $file.name
        Get-TopdeskAPIResponse -endpoint $weburl -downloadFile $filename | Out-Null
      }
    }
  }
  catch {
    throw $_
  }
  return $results.Results.dataset
}
