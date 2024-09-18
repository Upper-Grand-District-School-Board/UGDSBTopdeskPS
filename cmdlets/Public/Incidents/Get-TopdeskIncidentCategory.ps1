function Get-TopdeskIncidentCategory{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter()][string]$id,
    [Parameter()][string]$name
  ) 
  # The endpoint to get assets
  $endpoint = "/tas/api/incidents/categories"
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.Count) results."
    # Load results into an array
    foreach($item in $results.Results){
      if($id -and $item.id.trim() -ne $id){continue}
      elseif($name -and ($item.name).trim() -ne $name){continue}
      
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  } 
  return $data
}