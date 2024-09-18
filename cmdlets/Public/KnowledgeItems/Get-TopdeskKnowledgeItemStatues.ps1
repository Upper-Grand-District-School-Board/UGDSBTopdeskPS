function Get-TopdeskKnowledgeItemStatues{
  [cmdletbinding()]
  param(
    [Parameter()][bool]$archived
  )  
  $endpoint = "/services/knowledge-base-v1/knowledgeItemStatuses"
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If archived is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("archived")) { $uriparts.add("archived=$($archived)") }   
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
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