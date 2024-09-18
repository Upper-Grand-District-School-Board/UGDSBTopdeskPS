function New-TopdeskIncidentAttachment{
  [CmdletBinding()]
  [Alias("Add-TopdeskIncidentAttachment")]
  param(
    [Alias("id")][Parameter(Mandatory = $true, ParameterSetName = "id")][ValidateNotNullOrEmpty()][string]$incidentId,
    [Parameter(Mandatory = $true, ParameterSetName = "number")][ValidateNotNullOrEmpty()][string]$incidentNumber,
    [Parameter()][switch]$non_api_attachment_urls,
    [Parameter()][ValidateNotNullOrEmpty()][string]$filepath,
    [Parameter()][ValidateNotNullOrEmpty()][string]$filename,
    [Parameter()][switch]$invisibleForCaller,
    [Parameter()][ValidateNotNullOrEmpty()][string]$description
  )
  if($PSBoundParameters.ContainsKey("incidentId")){
    $endpoint = "/tas/api/incidents/id/$($incidentid)/attachments"
  }
  elseif($PSBoundParameters.ContainsKey("incidentNumber")){
    $endpoint = "/tas/api/incidents/number/$($incidentNumber)/attachments"
  }
  $fileContentEncoded = [convert]::ToBase64String((get-content $filepath -AsByteStream -Raw))
  $header = $global:topdeskHeader.Clone()
  $header."content-type" = "multipart/form-data; boundary=BOUNDARY"

  $body = @"
--BOUNDARY
Content-Disposition: form-data; name="invisibleForCaller"

$($invisibleForCaller.IsPresent)
--BOUNDARY
Content-Disposition: form-data; name="description"

$($description) 
--BOUNDARY
Content-Disposition: form-data; name="file"; filename="$($filename)"
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: base64

$($fileContentEncoded)
--BOUNDARY--
"@
  try {
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Method "Post" -headers $header -body $body -Verbose:$VerbosePreference
  }
  catch {
    if ($_.Exception.Message -eq "Conflict") {
      Write-Output "Image already exists ($($imagename)). Skipping."
    }
    else {
      throw $_ 
    }     
  }
  return $results.Results
}