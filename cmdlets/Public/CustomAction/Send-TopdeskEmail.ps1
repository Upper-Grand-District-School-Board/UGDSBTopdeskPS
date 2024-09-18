function Send-TopdeskEmail {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$from,
    [Parameter(Mandatory = $true)][string[]]$to,
    [Parameter()][string[]]$cc,
    [Parameter()][string[]]$bcc,
    [Parameter()][string]$replyTo,
    [Parameter(Mandatory = $true)][string]$subject,
    [Parameter(Mandatory = $true)][string]$body,
    [Parameter()][switch]$isHtmlBody,
    [Parameter()][int]$priority = 3,
    [Parameter()][switch]$requestDeliveryReceipt,
    [Parameter()][switch]$requestReadReceipt,
    [Parameter()][switch]$issuppressAutomaticReplies,
    [Parameter()][string]$attachments
  )
  $endpoint = "/services/email-v1/api/send"
  $mail = @{
    from                       = $from
    to                         = ($to -join ",")
    subject                    = $subject
    body                       = $body
    isHtmlBody                 = $isHtmlBody.IsPresent
    priority                   = $priority
    requestDeliveryReceipt     = $requestDeliveryReceipt.IsPresent
    requestReadReceipt         = $requestReadReceipt.IsPresent
    issuppressAutomaticReplies = $issuppressAutomaticReplies.IsPresent
  }
  if ($PSBoundParameters.ContainsKey("cc")){
    $mail.Add("cc", ($cc -join ",")) | Out-Null
  }
  if ($PSBoundParameters.ContainsKey("bcc")){
    $mail.Add("bcc", ($bcc -join ",")) | Out-Null
  } 
  if ($PSBoundParameters.ContainsKey("replyTo")){
    $mail.Add("replyTo", $replyTo) | Out-Null
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($mail | ConvertTo-Json) -Verbose:$VerbosePreference -Method "post" | Out-Null
  } 
  catch{
    throw $_
  } 
}