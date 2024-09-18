function New-TopdeskHTMLtoPDF {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$html,
    [Parameter(Mandatory = $true)][string]$downloadFile,
    [Parameter()][string]$format,
    [Parameter()][string]$margin_top,
    [Parameter()][string]$margin_bottom,
    [Parameter()][string]$margin_left,
    [Parameter()][string]$margin_right
  )
  $endpoint = "/services/pdf-generator-v1/convert/html"
  $pdf = @{
    html         = $html
    downloadFile = $downloadFile
  }
  if ($PSBoundParameters.ContainsKey("format")) {
    $pdf.Add("format", $format)
  }
  foreach ($item in ($PSBoundParameters.keys | Where-Object { $_ -like "margin*" })) {
    $pdf.add($item, (Get-Variable -Name $item).value)
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($pdf | ConvertTo-Json) -Verbose:$VerbosePreference -Method "post" -downloadFile $downloadFile  | Out-Null
  } 
  catch{
    throw $_
  }
}