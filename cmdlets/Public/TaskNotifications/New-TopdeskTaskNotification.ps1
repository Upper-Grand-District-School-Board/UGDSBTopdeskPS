function New-TopdeskTaskNotification{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$title,
    [Parameter(Mandatory = $true)][string]$body,
    [Parameter()][string]$url,
    [Parameter()][string[]]$operatorIds,
    [Parameter()][string[]]$operatorGroupIds
  )  
  $endpoint = "/tas/api/tasknotifications/custom"
  $task = @{
    title = $title
    body = $body
  }
  if ($PSBoundParameters.ContainsKey("url")){
    $task.Add("url", $url) | Out-Null
  }  
  if ($PSBoundParameters.ContainsKey("operatorIds")){
    $task.Add("operatorIds", $operatorIds) | Out-Null
  }  
  if ($PSBoundParameters.ContainsKey("operatorGroupIds")){
    $task.Add("operatorGroupIds", $operatorGroupIds) | Out-Null
  }   
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($task | ConvertTo-Json) -Verbose:$VerbosePreference -Method "post" | Out-Null
  } 
  catch{
    throw $_
  } 
}