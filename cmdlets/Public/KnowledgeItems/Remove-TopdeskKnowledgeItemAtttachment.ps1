function Remove-TopdeskKnowledgeItemAtttachment{
  [CmdletBinding()]
  param(  
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$attachmentIdentifier
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/attachments/$($attachmentIdentifier)"
  try {
    Get-TopdeskAPIResponse -endpoint $endpoint -Method Delete -Verbose:$VerbosePreference | Out-Null
  }
  catch {
    throw $_
  }   
}