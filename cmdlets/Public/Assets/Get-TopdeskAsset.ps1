<#
  .DESCRIPTION
  This will query and return all the assets from the topdesk platform.
  .PARAMETER nameFragment
  Filters assets by checking whether their name contains this search term. Matching is case insensitive. Special and whitespace characters are supported without the need to escape them. An empty value matches all assets.
  .PARAMETER searchTerm
  To filter assets by their name-fragment or any fragment in their text or number type fields. It's case-insensitive
  .PARAMETER templateId
  To filter assets by a specific template. Since each asset type uses only one template, this filtering is the same as filtering by asset types
  .PARAMETER templateName
  To filter assets by a specific template's name (case sensitive)
  .PARAMETER includeTemplates
  Whether to include template information in the response. It can be one of the following: none (default if omitted), relevant (works only if linkedTo is present), all.
  .PARAMETER archived
  Whether to show archived assets. Leave out for all, or specify true/false for only archived, or only active assets, respectively.
  .PARAMETER fields
  Specifies the set of returned asset fields and auxiliary asset information. Field names are to be provided as a comma-separated list of the same query parameter. The specified pieces of information are returned inside the 'dataSet' array. Additional meta-data about the requested fields (like their type and display name) is returned in the 'columns' array of the response. Possible values are the following:
  
  The ID of any user-defined field can be used.
  Standard asset properties: 'name', 'modificationDate', 'creationDate'.
  '@type': Template name and icon name of the asset.
  '@@summary': a user-defined description of the asset which is built by concatenating field values.
  '@assignments': Information about assignments (person / person group / location / branch links) of the particular asset.
  '@linkToTemplateCount': This field can only be used together with 'linkedToTemplate', 'linkedToTemplateWithDirection', and optionally with 'linkedToTemplateWithCapability' query parameters. When this special field is given, the response will contain the count of assets of the specified template which are linked to the given asset with the specified direction and capability. If 'linkedToTemplateWithCapability' isn't given, the unqualified parent-child relationship is assumed. (For example, this feature can be used to query how many assets of a certain asset type are in each stock.)  
  .PARAMETER showAssignments
  When it's given it returns more meta information, including all person and location related assignments. See '/assignments' endpoint documentation for more details about the response format.
  .PARAMETER linkedTo
  Entity type and ID of the entity the assets are linked to, separated by a slash character. Accepted types: assignable types (person, personGroup, branch, location) and external link types (incident, changeActivity, knowledge, change, problem, omActivity, omSeries, service).

  Example: linkedTo=person/4878f620-e404-4f2d-9d53-622a1693d467.
  Instead of an ID, wildcards can also be used with certain types. In that case, and only then, multiple type/value pairs are also accepted, which should be separated by a comma.
  Supported wildcards are:
  'any' for any active or archived entities. Supported for the following types: person, personGroup, branch, location.
  'anyArchived' for any archived entities. Supported for the following types: person, personGroup.
  Example: linkedTo=person/any,personGroup/anyArchived. This filters for assets that are linked to any person or linked to any archived person group.
  At most one type/value pair can be specified when the type is an external link type, and it cannot be combined with assignable types.
  .PARAMETER notLinkedTo
  Entity type and ID of the entity the assets are not linked to, separated by a slash character. Accepted types are the same as for linkedTo.

  Example: notLinkedTo=person/4878f620-e404-4f2d-9d53-622a1693d467.
  Instead of an ID, wildcards can also be used with certain types. In that case, and only then, multiple type/value pairs are also accepted, which should be separated by a comma.
  Supported wildcards are:
  'any' for any active or archived entities. Supported for the following types: person, personGroup, branch, location.
  'anyArchived' for any archived entities. Supported for the following types: person, personGroup.
  Example: notLinkedTo=person/any,personGroup/anyArchived. This filters for assets that are not linked to any person or not linked to any archived person group.
  At most one type/value pair can be specified when the type is an external link type, and it cannot be combined with assignable types.
  .PARAMETER filterInherited
  Used together with linkedTo or notLinkedTo parameters. Whether to filter assets by including inherited assignments.

  For example:

  Using filterInherited=false and linkedTo=person/4878f620-e404-4f2d-9d53-622a1693d467 lists all assets which have this person assigned directly, but skips assets where this person is assigned only by inheritance.
  Using filterInherited=true and linkedTo=person/4878f620-e404-4f2d-9d53-622a1693d467 lists all assets which have this person assigned, either directly or by inheritance.
  .PARAMETER assetStatus
  To filter assets by their status. Possible values: OPERATIONAL, IMPACTED.
  .PARAMETER filter
  Supports a limited set of simple OData filters. Specifying multiple filters is supported, but they can be separated only by the 'and' logical operator.

  Filtering based on the name field with greater-than operator. Example: $filter=name gt 'CAR0042'.
  Filtering based on the templateId field. Supported operators: eq, in, ne. Example: $filter=templateId eq 'fc886aa0-8315-4ff9-b7f9-ad79a01d5f5c' and templateId eq '3c5f3383-23d5-40bf-95f0-78b151c028ea'.
  Filtering based on date fields with greater-than, or less-than operator. Example: $filter=modificationDate gt '2017' and modificationDate lt '2017-05-26'.
  Dates are interpreted as UTC dates.
  Supported formats: yyyy (2017); yyyy-MM (2017-12); yyyy-MM-dd (2017-12-25); yyyy-MM-dd'T'HH:mm (2017-12-25T18:30); yyyy-MM-dd'T'HH:mm:ss (2017-12-25T18:30:12); yyyy-MM-dd'T'HH:mm:ss.SSS (2017-12-25T18:30:12.798).
  Filtering based on a linked entity. Example: $filter=linkedTo eq 'incident/2eebf650-c5d7-4bf3-ad05-1f4cbced3b06'.
  Filtering based on a text field. Use the 'contains' operator. Example: $filter=specification contains 'desk'.
  Filtering based on a checkbox field on false and true values. Example: $filter=termsandconditions eq 'false'.
  Filtering based on a number field. Examples: $filter=cost eq 15, $filter=cost ge 40.
  Filtering based on a dropdown field. Supported operators: eq, in, ne. Example: $filter=dropdown-field eq '2eebf650-c5d7-4bf3-ad05-1f4cbced3b06'.
  Filtering based on whether a text, number, dropdown or date field is empty or not empty. Missing values and empty strings are considered empty. Fields that do not exist for a given type are considered neither empty nor not empty. Examples: $filter=text-field isEmpty, $filter=text-field isNotEmpty.
  Filtering based on the id field with 'eq' or 'in' operator. Examples: $filter=id eq 'e08dcc19-8008-436e-82f1-c99b1cf9d727', $filter=id in ['e08dcc19-8008-436e-82f1-c99b1cf9d727','23c484cd-cdcf-48ae-a7bd-b655efb3c686'].
  .PARAMETER orderby
  OData like ordering on assets based on the value of a single field specified by this parameter. Secondary ordering is always performed by name. Sorting direction needs to be set to either asc or desc. Currently, sorting can be based on the following types of fields: text (including name and @@summary), date (including modificationDate and creationDate), number, boolean, and dropdown with own options.
  .PARAMETER lastSeenName
  Can be used for implementing seek-based paging. Skips assets whose name precedes or equals to the value of this parameter according to the sorting direction. Can be used together with lastSeenOrderbyValue and $orderby. If lastSeenOrderbyValue is not present, using this parameter leads to a bad request error.
  Note: Using this parameter is only supported when $orderby is set to either name, @@summary, modificationDate, or creationDate.
  .PARAMETER lastSeenOrderbyValue
  Can be used for implementing seek-based paging. Skips assets that have a preceding value for the field specified in $orderby compared to the value of this parameter. In case of value equality the value of lastSeenName determines whether to skip an asset or not. Can be used together with lastSeenName and $orderby. When sorting is based on the name only, the value of this parameter should be the same as the value of lastSeenName. If lastSeenName is not present, using this parameter leads to a bad request error
  .PARAMETER linkableToAsset
  Used together with linkableWithDirection and optionally with linkableWithCapability. To filter assets by checking if they can be linked to the asset specified by its unique ID. An asset cannot be linked to itself. The same link cannot be applied multiple times. If linkableWithDirection is not provided, using this parameter results in a 'Bad Request' error. If linkableWithCapability is not provided, resulting assets are linkable without a link type.
  .PARAMETER linkableWithDirection
  Used together with linkableToAsset and optionally with linkableWithCapability. To filter assets by direction. Possible values: SOURCE, TARGET.
  SOURCE: linkableToAsset can be the parent of results.
  TARGET: linkableToAsset can be the child of results.
  If linkableToAsset is not provided, using this parameter results in a 'Bad Request' error. If linkableWithCapability is not provided, resulting assets are linkable without a link type.
  .PARAMETER linkableWithCapability
  Used together with linkableWithDirection and linkableToAsset. To filter assets by a link type specified by its unique ID. If either linkableWithDirection or linkableToAsset is not provided, using this parameter results in a 'Bad Request' error.
  .PARAMETER linkedToAsset
  Used together with linkedWithDirection and optionally with linkedWithCapability. To filter assets by checking if they are linked to the asset specified by its unique ID. If linkedWithDirection is not provided, using this parameter results in a 'Bad Request' error. If linkedWithCapability is not provided, resulting assets are linked without a link type. In addition to a unique ID of an asset, the following values are also valid for the parameter:
  any: results in assets that are linked to any asset with the specified direction and link type.
  none: results in assets that are not linked to any asset with the specified direction and link type.  
  .PARAMETER linkedWithDirection
  Used together with linkedToAsset and optionally with linkedWithCapability. To filter assets by direction. Possible values: SOURCE, TARGET.
  SOURCE: linkedToAsset can be the parent of results.
  TARGET: linkedToAsset can be the child of results.
  If linkedToAsset is not provided, using this parameter results in a 'Bad Request' error. If linkedWithCapability is not provided, resulting assets are linked without a link type.
  .PARAMETER linkedWithCapability
  Used together with linkedWithDirection and linkedToAsset. To filter assets by a link type specified by its unique ID. If either linkedWithDirection or linkedToAsset is not provided, using this parameter results in a 'Bad Request' error.
  .PARAMETER resourceCategory
  The endpoint returns assets matching the specified category only.
  .PARAMETER includeInherited
  Show inherited assignments of assets.
  .PARAMETER pageStart
  The number of assets to skip, or, in other words, the zero-based index of the asset to return as the first item of the requested page. In case the value is greater than or equal to the total number of retrieved assets the resulting list is empty. This parameter cannot be used together with either lastSeenName or lastSeenOrderbyValue, as they provide an alternative way of paging.
  .PARAMETER fetchData
  Whether to include assets in the response or not.
  .PARAMETER fetchCount
  Whether to include the asset count in the response or not. This parameter is especially useful if the number of assets is needed. With this solution, counting the assets on client side can be avoided, as the count is available in the count property of the response body.
  .PARAMETER resolveDropdownOptions
  Whether to turn the value of dropdown fields into an object that contains the display name of options next to their ID. This could be useful when you want to avoid making many additional requests for retrieving display names, which can be performed on a per dropdown option basis like this: GET /assets?templateId=<ID of the dropdown template>&id=<ID of the dropdown option>. The 'id' and 'name' properties of the object are present with null value when the corresponding asset has no value for a particular dropdown field.
#>
function Get-TopdeskAsset {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter()][string]$assetId,
    [Parameter()][switch]$defaultfields,
    [Parameter()][string]$fields = "",
    [Parameter()][string][ValidateNotNullOrEmpty()]$nameFragment,
    [Parameter()][string][ValidateNotNullOrEmpty()]$searchTerm,
    [Parameter()][string][ValidateNotNullOrEmpty()]$templateId,
    [Parameter()][string][ValidateNotNullOrEmpty()]$templateName,
    [Parameter()][bool][ValidateNotNullOrEmpty()]$archived,
    [Parameter()][switch]$showAssignments,
    [Parameter()][ValidateSet("OPERATIONAL", "IMPACTED")][string]$assetStatus,
    [Parameter()][string][ValidateNotNullOrEmpty()]$filter,
    [Parameter()][string][ValidateNotNullOrEmpty()]$orderbyname = "name",
    [Parameter()][ValidateSet("asc", "desc")][string][ValidateNotNullOrEmpty()]$orderbydirection = "asc",
    [Parameter()][string][ValidateNotNullOrEmpty()]$lastSeenName,
    [Parameter()][string][ValidateNotNullOrEmpty()]$lastSeenOrderbyValue,
    [Parameter()][ValidateSet("asset", "stock", "bulkItem")][string]$resourceCategory,
    [Parameter()][bool][ValidateNotNullOrEmpty()]$includeInherited,
    [Parameter()][int][ValidateNotNullOrEmpty()]$pageStart,
    [Parameter()][bool][ValidateNotNullOrEmpty()]$fetchData,
    [Parameter()][switch]$fetchCount,
    [Parameter()][switch]$resolveDropdownOptions,
    [Parameter()][ValidateSet("none", "relevant", "all")][string]$includeTemplates,
    [Parameter()][string][ValidateNotNullOrEmpty()]$linkedTo,
    [Parameter()][string][ValidateNotNullOrEmpty()]$notLinkedTo,
    [Parameter()][bool]$filterInherited,
    [Parameter()][string][ValidateNotNullOrEmpty()]$linkableToAsset,
    [Parameter()][string][ValidateNotNullOrEmpty()]$linkableWithDirection,
    [Parameter()][string][ValidateNotNullOrEmpty()]$linkableWithCapability,
    [Parameter()][string][ValidateNotNullOrEmpty()]$linkedToAsset,
    [Parameter()][string][ValidateNotNullOrEmpty()]$linkedWithDirection,
    [Parameter()][string][ValidateNotNullOrEmpty()]$linkedWithCapability,
    [Parameter()][switch]$all
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/assetmgmt/assets"
  # If fields is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("assetId")) { 
    $endpoint = "/tas/api/assetmgmt/assets/$($assetid)"
  }  
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If default fields are present, then ensure that we include those fields at a minimum
  if ($defaultfields.IsPresent) {
    $fields = "text,archived,id,name,$($fields)"
  }
  # If fields is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("fields")) { $uriparts.add("fields=$($fields)") }
  # If name fragment is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("nameFragment")) { $uriparts.add("nameFragment=$($nameFragment)") }
  # If searchTerm is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("searchTerm")) { $uriparts.add("searchTerm=$($searchTerm)") }  
  # If templateId is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("templateId")) { $uriparts.add("templateId=$($templateId)") }    
  # If templateName is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("templateName")) { $uriparts.add("templateName=$($templateName)") }    
  # If archived is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("archived")) { $uriparts.add("archived=$($archived)") }   
  # If showAssignments is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("showAssignments")) { $uriparts.add("showAssignments=$($showAssignments)") }  
  # If assetStatus is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("assetStatus")) { $uriparts.add("assetStatus=$($assetStatus)") }   
  # If filter is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("filter")) { $uriparts.add("`$filter=$($filter)") }
  # Order by
  $uriparts.add("`$orderby=$($orderbyname) $($orderbydirection)")
  # If lastSeenName is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("lastSeenName")) { $uriparts.add("lastSeenName=$($lastSeenName)") }
  # If lastSeenName is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("lastSeenOrderbyValue")) { $uriparts.add("lastSeenOrderbyValue=$($lastSeenOrderbyValue)") }
  # If lastSeenName is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("resourceCategory")) { $uriparts.add("resourceCategory=$($resourceCategory)") }   
  # If lastSeenName is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("includeInherited")) { $uriparts.add("includeInherited=$($includeInherited)") }   
  # If pageStart is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("pageStart")) { $uriparts.add("pageStart=$($pageStart)") }    
  # If fetchData is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("fetchData")) { $uriparts.add("fetchData=$($fetchData)") }    
  # If fetchCount is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("fetchCount")) { $uriparts.add("fetchCount=$($fetchCount)") }    
  # If resolveDropdownOptions is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("resolveDropdownOptions")) { $uriparts.add("resolveDropdownOptions=$($resolveDropdownOptions)") }
  # If includeTemplates is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("includeTemplates")) { $uriparts.add("includeTemplates=$($includeTemplates)") }      
  # If linkedTo is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("linkedTo")) { $uriparts.add("linkedTo=$($linkedTo)") } 
  # If notLinkedTo is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("notLinkedTo")) { $uriparts.add("notLinkedTo=$($notLinkedTo)") }   
  # If filterInherited is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("filterInherited")) { $uriparts.add("filterInherited=$($filterInherited)") } 
  # If linkableToAsset is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("linkableToAsset")) { $uriparts.add("linkableToAsset=$($linkableToAsset)") } 
  # If linkableWithDirection is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("linkableWithDirection")) { $uriparts.add("linkableWithDirection=$($linkableWithDirection)") } 
  # If linkableWithCapability is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("linkableWithCapability")) { $uriparts.add("linkableWithCapability=$($filterInherited)") } 
  # If linkedToAsset is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("linkedToAsset")) { $uriparts.add("linkedToAsset=$($linkedToAsset)") } 
  # If linkedWithDirection is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("linkedWithDirection")) { $uriparts.add("linkedWithDirection=$($linkedWithDirection)") } 
  # If linkedWithCapability is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("linkedWithCapability")) { $uriparts.add("linkedWithCapability=$($linkedWithCapability)") }           
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"
  try {
    # Array to hold results from the API call
    $data = [System.Collections.Generic.List[PSObject]]@()
    $uri = $endpoint
    do {
      # Execute API Call
      $results = Get-TopdeskAPIResponse -endpoint $uri -Verbose:$VerbosePreference
      if($results.results.dataSet.count -gt 0){
        $process = $results.results.dataSet
      }
      else{
        $process = $results.results
      }
      # Load results into an array
      foreach ($item in $process) {
        $data.Add($item) | Out-Null
      }      
      Write-Verbose "Returned $($results.Results.dataSet.Count) results. Current result set is $($data.Count) items."      
      $uri = "$($endpoint)&lastSeenName='$($data[$data.count - 1].Name)'&lastSeenOrderbyValue='$($data[$data.count - 1].Name)'"
    }
    while ($all.IsPresent -and $results.StatusCode -eq 206)
    if ($PSBoundParameters.ContainsKey("includeTemplates")) {
      $templates = [System.Collections.Generic.List[PSObject]]@()
      foreach ($item in $results.Results.templates) {
        $templates.Add($item) | Out-Null
      }      
    }
  }
  catch {
    throw $_
  }
  # return the data
  if ($PSBoundParameters.ContainsKey("includeTemplates")) {
    return [PSCustomObject]@{
      data      = $data
      templates = $templates
    }
  }
  else {
    return $data
  }
}