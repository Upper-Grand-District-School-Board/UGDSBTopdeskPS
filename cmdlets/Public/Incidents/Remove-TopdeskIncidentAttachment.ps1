function Remove-TopdeskIncidentAttachment{
  [CmdletBinding()]
  param(  
    [Alias("incidentid")][Parameter(Mandatory = $true, ParameterSetName = "id")][ValidateNotNullOrEmpty()][string]$id,
    [Alias("incidentnumber")][Parameter(Mandatory = $true, ParameterSetName = "number")][ValidateNotNullOrEmpty()][string]$number,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$attachmentid
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/attachments/$($attachmentid)"
  }
  if ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/attachments/$($attachmentid)"
  }  
  try {
    Get-TopdeskAPIResponse -endpoint $endpoint -Method Delete -Verbose:$VerbosePreference | Out-Null
  }
  catch {
    throw $_
  }   
}