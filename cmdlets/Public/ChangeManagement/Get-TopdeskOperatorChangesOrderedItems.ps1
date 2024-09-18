function Get-TopdeskOperatorChangesOrderedItems{
  [CmdletBinding()]
  [Alias("Get-TopdeskOrderedItems")]
  param(
    [Alias("changeID")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/operatorChanges/$($id)/orderedItems"  
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