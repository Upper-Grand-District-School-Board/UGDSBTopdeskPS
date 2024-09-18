function Get-TopdeskOperatorChangesRequests{
  [CmdletBinding()]
  [Alias("Get-TopdeskChangeRequestText")]
  param(
    [Alias("changeID")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter()][switch]$inlineimages,
    [Parameter()][switch]$browserFriendlyUrls
  )  
  # The endpoint to get assets
  $endpoint = "/tas/api/operatorChanges/$($id)/requests"
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  ## If inlineimages is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("inlineimages")) { $uriparts.add("inlineimages=$($inlineimages.isPresent)") }    
  ## If browserFriendlyUrls is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("browserFriendlyUrls")) { $uriparts.add("browserFriendlyUrls=$($browserFriendlyUrls.isPresent)") }  
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
  # Array to hold results from the API call
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.Results.Count) results."
    # Load results into an array
    foreach($item in $results.Results.Results){
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return $data  
}