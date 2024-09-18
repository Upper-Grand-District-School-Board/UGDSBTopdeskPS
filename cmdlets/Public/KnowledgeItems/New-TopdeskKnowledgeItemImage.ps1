function New-TopdeskKnowledgeItemImage {
  [cmdletbinding()]
  param(
    [Alias("id")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$identifier,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$filepath
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($identifier)/images"
  $header = $global:topdeskHeader.Clone()
  $header."content-type" = "multipart/form-data"
  $form = @{
    file = Get-Item $filepath
  }
  try{
    Get-TopdeskAPIResponse -endpoint $endpoint -Method Post -headers $header -form $form -AllowInsecureRedirect -Verbose:$VerbosePreference | Out-Null
  }
  catch{
    throw $_
  }
}