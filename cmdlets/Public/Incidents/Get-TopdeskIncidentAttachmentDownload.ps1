function Get-TopdeskIncidentAttachmentDownload{
  [CmdletBinding()]
  param(  
    [Alias("incidentid")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$attachmentid,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$downloadFile
  )
  $endpoint = "/tas/api/incidents/id/$($id)/attachments/$($attachmentid)/download"
  try {
    Get-TopdeskAPIResponse -endpoint $endpoint -downloadFile $downloadFile -Verbose:$VerbosePreference | Out-Null
  }
  catch {
    throw $_
  }    
}
