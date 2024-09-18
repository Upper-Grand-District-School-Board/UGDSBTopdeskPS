function Get-TopdeskKnowledgeItemBranches{
  [cmdletbinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id
  ) 
  # The endpoint to get assets
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/branches"
  # Array to hold results from the API call
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.Count) results."
    # Load results into an array
    foreach($item in $results.Results){
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return $data     
}