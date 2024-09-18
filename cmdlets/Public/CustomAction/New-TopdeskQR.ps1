function New-TopdeskQR{
  [CmdletBinding()]
  param(
    [Parameter()][string]$format = "QR_CODE",
    [Parameter()][int]$width = 400,
    [Parameter()][int]$height = 400,
    [Parameter()][string]$imageType = "PNG",
    [Parameter(Mandatory = $true)][string]$text,
    [Parameter()][string]$header,
    [Parameter()][string]$footer,
    [Parameter(Mandatory = $true)][string]$downloadFile
  )
  $endpoint = "/solutions/multi-barcode-creator-1/qr"
  $body = @{
    metadata = @{
      format = $format
      width = $width
      height = $height
      imageType = $imageType
    }
    content = @{
      text = $text
    }
  }
  if ($PSBoundParameters.ContainsKey("header")) {
    $body.content.Add("header", $header)
  }
  if ($PSBoundParameters.ContainsKey("footer")) {
    $body.content.Add("footer", $footer)
  }   
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($body | ConvertTo-Json) -Verbose:$VerbosePreference -Method "post" -downloadFile $downloadFile  | Out-Null
  } 
  catch{
    throw $_
  }   
}