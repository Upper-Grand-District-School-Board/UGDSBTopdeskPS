function Update-TopdeskKnowledgeItemTranslation{
  [cmdletbinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter()][string]$language = "en-CA",
    [Parameter(Mandatory = $true, ParameterSetName = 'body')][PSCustomObject]$body,
    [Parameter(ParameterSetName = 'Title')][string]$title,
    [Parameter(ParameterSetName = 'Title')][string]$description,
    [Parameter(ParameterSetName = 'Title')][string]$content,
    [Parameter(ParameterSetName = 'Title')][string]$commentsForOperators,
    [Parameter(ParameterSetName = 'Title')][string]$keywords
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/translations/$($language)"
  if (-not $PSBoundParameters.ContainsKey("body")){
    $body = @{}
    if ($PSBoundParameters.ContainsKey("title")){$body.Add("title",$title) | Out-Null}
    if ($PSBoundParameters.ContainsKey("description")){$body.Add("description",$description) | Out-Null}
    if ($PSBoundParameters.ContainsKey("content")){$body.Add("content",$content) | Out-Null}
    if ($PSBoundParameters.ContainsKey("commentsForOperators")){$body.Add("commentsForOperators",$commentsForOperators) | Out-Null}
    if ($PSBoundParameters.ContainsKey("keywords")){$body.Add("keywords",$keywords) | Out-Null}
  }
  try{
    Get-TopdeskAPIResponse -endpoint $endpoint -Method "POST" -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference | Out-Null
    Write-Verbose "Updating knowledgeitem with id $($id) from system." 
  } 
  catch{
    throw $_
  }   
}