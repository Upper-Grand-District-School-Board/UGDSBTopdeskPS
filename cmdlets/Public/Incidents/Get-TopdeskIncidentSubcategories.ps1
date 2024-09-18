function Get-TopdeskIncidentSubcategories{
  [CmdletBinding()]
  [Alias("Get-TopdeskIncidentSubcategory")]
  param(
    [Parameter()][string]$id,
    [Parameter()][string]$name,
    [Alias("category_id")][Parameter()][string]$categoryid,
    [Alias("category_name")][Parameter()][string]$categoryname    
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/incidents/subcategories"
  $data = [System.Collections.Generic.List[PSObject]]@()  
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.Count) results."
    # Load results into an array
    foreach($item in $results.Results){
      if($id -and $item.id.trim() -ne $id){continue}
      elseif($name -and ($item.name).trim() -ne $name){continue}
      if($categoryid -and $item.category.id -ne $categoryid){continue}
      elseif($categoryname -and $item.category.name.trim() -ne $categoryname){continue}
      
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  } 
  return $data  
}
