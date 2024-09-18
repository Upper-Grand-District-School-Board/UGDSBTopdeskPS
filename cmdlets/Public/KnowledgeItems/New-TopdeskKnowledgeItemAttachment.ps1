function New-TopdeskKnowledgeItemAttachment {
  [CmdletBinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$filepath,
    [Parameter()][ValidateNotNullOrEmpty()][string]$description
  )
  $endpoint = "/tas/api/knowledgeItems/$($id)/attachments"
  $header = $global:topdeskHeader.Clone()
  $header."content-type" = "multipart/form-data"
  $form = @{
    file = Get-Item $filepath
    description = $description
  }
  try{
    Get-TopdeskAPIResponse -endpoint $endpoint -Method Post -headers $header -form $form  -AllowInsecureRedirect -Verbose:$VerbosePreference | Out-Null
  }
  catch{
    throw $_
  } 
}