function Get-TopdeskAssetActions{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$assetId
  )
  $endpoint = "/tas/api/assetmgmt/assets/$($assetId)/actions"
  # Array to hold results from the API call
  $data = [System.Collections.Generic.List[PSObject]]@()  
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.actions.count) results."
    # Load results into an array
    foreach($item in $results.Results.actions){
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return $data     
}