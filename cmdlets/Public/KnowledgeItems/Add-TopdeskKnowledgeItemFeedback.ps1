function Add-TopdeskKnowledgeItemFeedback{
  [cmdletbinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter()][switch]$questionAnswered,
    [Parameter()][ValidateNotNullOrEmpty()][string]$feedbackText
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/giveFeedback"
  $body = @{
    questionAnswered = $questionAnswered.IsPresent
    feedbackText     = $feedbackText
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($body | ConvertTo-Json) -Verbose:$VerbosePreference -Method "post" | Out-Null
  } 
  catch{
    throw $_
  }   
}