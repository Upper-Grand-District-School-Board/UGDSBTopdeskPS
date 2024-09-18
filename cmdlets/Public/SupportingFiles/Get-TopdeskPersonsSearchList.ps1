function Get-TopdeskPersonsSearchList{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter()][int[]]$tab = @(1, 2),
    [Parameter()][int[]]$searchList = @(1, 2, 3, 4, 5),
    [Parameter()][string]$external_link_id,
    [Parameter()][string]$external_link_type
  )
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  if ($PSBoundParameters.ContainsKey("external_link_id")) { $uriparts.add("external_link_id=$($external_link_id)") } 
  if ($PSBoundParameters.ContainsKey("external_link_type")) { $uriparts.add("external_link_type=$($external_link_type)") } 
  # Array to hold results from the API call
  $data = [System.Collections.Generic.List[PSObject]]@()  
  # Loop through selected tabs
  foreach ($t in $tab) {
    #$t
    # Loop through search lists
    foreach ($list in $searchList) {
      #$list
      $endpoint = "/tas/api/persons/free_fields/$($t)/searchlists/$($list)"
      # Generate the final API endppoint URI
      $endpoint = "$($endpoint)?$($uriparts -join "&")"      
      try {
        # Execute API Call
        $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
        #$results
        Write-Verbose "Returned $($results.Results.Count) results."
        # Load results into an array
        foreach ($item in $results.Results) {
          $item | Add-Member -MemberType NoteProperty -Name "Tab" -Value $t -Force
          $item | Add-Member -MemberType NoteProperty -Name "searchList" -Value $list -Force
          $data.add($item)
        }
        if($results.Results.count -eq 0 -and $includeEmpty.IsPresent){
          $item = [PSCUstomObject]@{
            Tab = $t
            SearchList = $list
          }
          $data.add($item)
        }
      } 
      catch {
        throw $_
      }
    }
  }
  return $data
}