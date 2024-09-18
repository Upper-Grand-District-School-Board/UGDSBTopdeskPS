function Set-TopdeskPersonsPrivateDetails{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true)][string]$id,
    [Parameter()][string]$privatePhoneNumber1,
    [Parameter()][string]$privatePhoneNumber2,
    [Parameter()][string]$privateMobilePhoneNumber,
    [Parameter()][string]$privateFaxNumber,
    [Parameter()][string]$socialSecurityNumber,
    [Parameter()][string]$privateEmail,
    [Parameter()][string]$country,
    [Parameter()][string]$street,
    [Parameter()][string]$number,
    [Parameter()][string]$county,
    [Parameter()][string]$city,
    [Parameter()][string]$postcode,
    [Parameter()][string]$addressMemo
  )
  $endpoint = "/tas/api/persons/id/$($id)/privateDetails"
  $body = @{}
  $address = @{}
  if ($PSBoundParameters.ContainsKey("privatePhoneNumber1")) { $body.Add("privatePhoneNumber1",$privatePhoneNumber1)}   
  if ($PSBoundParameters.ContainsKey("privatePhoneNumber2")) { $body.Add("privatePhoneNumber2",$privatePhoneNumber2)}   
  if ($PSBoundParameters.ContainsKey("privateMobilePhoneNumber")) { $body.Add("privateMobilePhoneNumber",$privateMobilePhoneNumber)}   
  if ($PSBoundParameters.ContainsKey("privateFaxNumber")) { $body.Add("privateFaxNumber",$privateFaxNumber)}   
  if ($PSBoundParameters.ContainsKey("socialSecurityNumber")) { $body.Add("socialSecurityNumber",$privateFaxNumber)}   
  if ($PSBoundParameters.ContainsKey("privateEmail")) { $body.Add("privateEmail",$privateFaxNumber)}   
  if ($PSBoundParameters.ContainsKey("country")) { $address.Add("country",$country)}   
  if ($PSBoundParameters.ContainsKey("street")) { $address.Add("street",$street)}   
  if ($PSBoundParameters.ContainsKey("number")) { $address.Add("number",$number)}   
  if ($PSBoundParameters.ContainsKey("city")) { $address.Add("city",$city)}   
  if ($PSBoundParameters.ContainsKey("postcode")) { $address.Add("postcode",$postcode)}   
  if ($PSBoundParameters.ContainsKey("addressMemo")) { $address.Add("addressMemo",$addressMemo)}
  if($address.count -gt 0){
    $body.Add("address",$address)
  }
  try {
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Method PATCH -body ($body | ConvertTo-Json) -Verbose:$VerbosePreference
  }
  catch {
    throw $_
  }  
  return $results.results 
}