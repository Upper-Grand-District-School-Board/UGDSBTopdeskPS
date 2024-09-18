function Get-TopdeskIncidentSearchList {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter()][int[]]$tab = @(1, 2),
    [Parameter()][int[]]$searchList = @(1, 2, 3, 4, 5),
    [Parameter()][switch]$includeEmpty
  )
  # Array to hold results from the API call
  $data = [System.Collections.Generic.List[PSObject]]@()  
  # Loop through selected tabs
  foreach ($t in $tab) {
    #$t
    # Loop through search lists
    foreach ($list in $searchList) {
      #$list
      $endpoint = "/tas/api/incidents/free_fields/$($t)/searchlists/$($list)"
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