function New-TopdeskAssetUpload{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$assetId,
    [Parameter(Mandatory = $true)][string]$uploadfile
  )
  $endpoint = "/tas/api/assetmgmt/uploads?assetId=$($assetid)"
  # Override the default header
  $header = $global:topdeskHeader.Clone()
  $header."content-type" = "multipart/form-data; boundary=BOUNDARY"
  $file = Get-Item $uploadfile
  $fileContentEncoded = [convert]::ToBase64String((get-content $file.FullName -AsByteStream -Raw))
  $body = @"
--BOUNDARY
Content-Disposition: form-data; name="file"; filename="$($file.Name)"
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: base64

$($fileContentEncoded)
--BOUNDARY--
"@
  Get-TopdeskAPIResponse -endpoint $endpoint -Method "Post" -headers $header -body $body -Verbose:$VerbosePreference
}
