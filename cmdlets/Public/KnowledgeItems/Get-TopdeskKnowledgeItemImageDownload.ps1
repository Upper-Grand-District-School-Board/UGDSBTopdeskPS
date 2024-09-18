function Get-TopdeskKnowledgeItemImageDownload{
  [CmdletBinding()]
  param(  
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$imageName,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$downloadFile
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/images/$($imageName)/download"
  try {
    Get-TopdeskAPIResponse -endpoint $endpoint -downloadFile $downloadFile -Verbose:$VerbosePreference | Out-Null
  }
  catch {
    throw $_
  }   
}