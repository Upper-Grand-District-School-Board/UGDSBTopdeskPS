function Get-TopdeskKnowledgeItemAttachmentDownload{
  [CmdletBinding()]
  param(  
    [Alias("incidentid")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$downloadFile,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$attachmentIdentifier
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/attachments/$($attachmentIdentifier)/download"
  try {
    Get-TopdeskAPIResponse -endpoint $endpoint -downloadFile $downloadFile -Verbose:$VerbosePreference | Out-Null
  }
  catch {
    throw $_
  }  
}