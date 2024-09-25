#Region '.\Public\Add-TopdeskIncidentTimespent.ps1' 0
function Add-TopdeskIncidentTimespent{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "id")][string][ValidateNotNullOrEmpty()]$id,
    [Parameter(Mandatory = $true, ParameterSetName = "number")][string][ValidateNotNullOrEmpty()]$number,
    [Parameter()][int]$timeSpent = 0,
    [Parameter()][string]$notes,
    [Parameter()][datetime]$entryDate = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"),
    [Parameter()][string]$operator,
    [Parameter()][string]$operatorGroup,
    [Parameter()][string]$reason
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/timespent"
  }
  elseif ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/timespent"
  }
  $body = @{
    timeSpent = $timeSpent
    notes = $notes
    entryDate = $entryDate
  }
  if ($PSBoundParameters.ContainsKey("operator")) {
    $body.Add("operator",@{id = $operator})
  }
  if ($PSBoundParameters.ContainsKey("operatorGroup")) {
    $body.Add("operatorGroup",@{id = $operatorGroup})
  }
  if ($PSBoundParameters.ContainsKey("reason")) {
    $body.Add("reason",@{id = $reason})
  }
  try{
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Method "POST" -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference | Out-Null
  }
  catch{
    throw $_
  }
  return $results.Results
}
#EndRegion '.\Public\Add-TopdeskIncidentTimespent.ps1' 41
#Region '.\Public\Add-TopdeskKnowledgeItemBranchesLink.ps1' 0
function Add-TopdeskKnowledgeItemBranchesLink{
  [cmdletbinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$branchid
  )  
  # The endpoint to get assets
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/branches/link"
  $body = @{
    "id" = $branchid
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($body | ConvertTo-Json) -Verbose:$VerbosePreference -Method "post" | Out-Null
  } 
  catch{
    throw $_
  }   
}
#EndRegion '.\Public\Add-TopdeskKnowledgeItemBranchesLink.ps1' 20
#Region '.\Public\Add-TopdeskKnowledgeItemFeedback.ps1' 0
function Add-TopdeskKnowledgeItemFeedback{
  [cmdletbinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter()][switch]$questionAnswered,
    [Parameter()][ValidateNotNullOrEmpty()][string]$feedbackText
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/giveFeedback"
  $body = @{
    questionAnswered = $questionAnswered.IsPresent
    feedbackText     = $feedbackText
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($body | ConvertTo-Json) -Verbose:$VerbosePreference -Method "post" | Out-Null
  } 
  catch{
    throw $_
  }   
}
#EndRegion '.\Public\Add-TopdeskKnowledgeItemFeedback.ps1' 21
#Region '.\Public\Get-TopdeskAPIResponse.ps1' 0
function Get-TopdeskAPIResponse {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true)][string]$endpoint,
    [Parameter()][Hashtable]$headers = $global:topdeskHeader,
    [Parameter()][ValidateNotNullOrEmpty()][string]$downloadFile,
    [Parameter()][ValidateSet("Get", "Post", "Patch", "Delete", "Put")][string]$Method = "Get",
    [Parameter()][ValidateNotNullOrEmpty()]$body,
    [Parameter()][ValidateNotNullOrEmpty()]$form,
    [Parameter()][switch]$AllowInsecureRedirect,
    [Parameter()][ValidateNotNullOrEmpty()][string]$filePath
  )
  $uri = "$($global:topdeskAPIEndpoint)$($endpoint)"
  try {
    $vars = @{
      Method                = $Method
      Uri                   = $Uri
      Headers               = $headers
      StatusCodeVariable    = 'statusCode'
      AllowInsecureRedirect = $AllowInsecureRedirect.IsPresent
    }
    if ($PSBoundParameters.ContainsKey("filePath")) {
      $vars.Add("infile", $filePath)
    }
    if ($PSBoundParameters.ContainsKey("downloadFile")) {
      $vars.Add("OutFile", $downloadFile)
    }
    if ($PSBoundParameters.ContainsKey("Body")) {
      $vars.Add("Body", $body)
    }
    if ($PSBoundParameters.ContainsKey("form")) {
      $vars.Add("form", $form)
    }
    Write-Verbose "Calling API endpoint: $($uri)"
    $results = Invoke-RestMethod @Vars
  }
  catch {
    $ErrorMsg = $GLOBAL:error[0]
    $terminatingError = $true
    switch ($ErrorMsg.Exception.StatusCode) {
      "Unauthorized" {
        $ErrorResponse = "Unauthorized. Please check your credentials"
      }
      "NotFound" {
        $ErrorResponse = "Endpoint not found. Please check the endpoint"
      }
      "Conflict" {
        $terminatingError = $false
        throw "Conflict"
      }
      "BadRequest" {
        $InnerError = ($ErrorMsg | ConvertFrom-JSON).errors 
        switch ($InnerError.errorCode) {
          "item_visibility_invalid" {
            $terminatingError = $false
            Write-Error "Child can not be less permissive then parent"
          }
          default {
            $terminatingError = $true
            throw $InnerError
          }
        }
      }      
      default {
        $ErrorResponse = "Unknown Error. $($ErrorMsg.Exception.Message)"
      }
    }
    if ($terminatingError) {
      $ErrorResponse = "$($ErrorResponse) - Line: $($ErrorMsg.InvocationInfo.ScriptLineNumber). Script: $($ErrorMsg.InvocationInfo.ScriptName). Command: $($ErrorMsg.InvocationInfo.Line). Error Details: $($ErrorMsg.ErrorDetails.Message)"
      throw $ErrorResponse    
    }
  }
  return [PSCustomObject]@{
    StatusCode = $statusCode
    Results    = $results
  }  
}
#EndRegion '.\Public\Get-TopdeskAPIResponse.ps1' 79
#Region '.\Public\Get-TopdeskArchivingReasons.ps1' 0
function Get-TopdeskArchivingReasons{
  [CmdletBinding()]
  param(  
  )
  $endpoint = "/tas/api/archiving-reasons"  
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
#EndRegion '.\Public\Get-TopdeskArchivingReasons.ps1' 21
#Region '.\Public\Get-TopdeskAsset.ps1' 0
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
#EndRegion '.\Public\Get-TopdeskAsset.ps1' 260
#Region '.\Public\Get-TopdeskAssetActions.ps1' 0
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
#EndRegion '.\Public\Get-TopdeskAssetActions.ps1' 23
#Region '.\Public\Get-TopdeskAssetAssignments.ps1' 0
<#
  .DESCRIPTION
  
  .PARAMETER assetId
  The ID of the asset
  .PARAMETER includeInherited
  Include inherited assignments in the response. Inherited assignments do not have a linkId, but have an inheritanceParentId (the id of the asset it is inherited from).
  .PARAMETER limit
  The maximum number of assignments to return in one response. Must be a decimal number greater than 0.fs
#>
function Get-TopdeskAssetAssignments{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$assetId,
    [Parameter()][switch]$includeInherited,
    [Parameter()][ValidateNotNullOrEmpty()][string]$limit
  )
  $endpoint = "/tas/api/assetmgmt/assets/$($assetId)/assignments"
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If includeInherited is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("includeInherited")) { $uriparts.add("includeInherited=$($includeInherited.IsPresent)") }   
  # If limit is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("limit")) { $uriparts.add("limit=$($limit)") }    
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"      
  # Array to hold results from the API call
  $locations = [System.Collections.Generic.List[PSObject]]@()
  $persons = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.Count) results."
    # Load results into an array
    foreach($item in $results.Results.locations){
      $locations.add($item) | Out-Null
    }
    foreach($item in $results.Results.persons){
      $persons.add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return [PSCustomObject]@{
    Locations = $locations
    Persons = $persons
  } 
}
#EndRegion '.\Public\Get-TopdeskAssetAssignments.ps1' 51
#Region '.\Public\Get-TopdeskAssetDropdown.ps1' 0
<#
  .DESCRIPTION
  
  .PARAMETER dropdownId
  The template ID or field key of the dropdown whose options to return.
  .PARAMETER includeArchived
  Whether to include archived dropdown options in the response. By default, only active dropdown options are returned.
#>
function Get-TopdeskAssetDropdown {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Alias("dropdownName")][Parameter(Mandatory = $true)][string]$dropdownId,
    [Parameter()][switch]$includeArchived
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/assetmgmt/dropdowns/$($dropdownId)?field=name&includeArchived=$($includeArchived.IsPresent)"
  # Array to hold results from the API call
  $data = [System.Collections.Generic.List[PSObject]]@()  
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.Results.count) results."
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
#EndRegion '.\Public\Get-TopdeskAssetDropdown.ps1' 34
#Region '.\Public\Get-TopdeskAssetFieldDefinition.ps1' 0
<#
  .DESCRIPTION
  
  .PARAMETER fieldId
  Id of the field
  .PARAMETER resourceCategory
  If possible functionalities should be included into the response
#>
function Get-TopdeskAssetFieldDefinition{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true)][string][ValidateNotNullOrEmpty()]$fieldId,
    [Parameter()][switch]$includeFunctionalities
  )  
  $endpoint = "/tas/api/assetmgmt/fields/$($fieldId)"
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()  
  # If includeFunctionalities is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("includeFunctionalities")) { $uriparts.add("includeFunctionalities=$($includeFunctionalities)") }  
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
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
#EndRegion '.\Public\Get-TopdeskAssetFieldDefinition.ps1' 39
#Region '.\Public\Get-TopdeskAssetFields.ps1' 0
<#
  .DESCRIPTION
  
  .PARAMETER searchTerm
  Include fields only if their display name contains the given text fragment.
  .PARAMETER resourceCategory
  The endpoint returns assets matching the specified category only.
#>
function Get-TopdeskAssetFields{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter()][ValidateNotNullOrEmpty()][string]$searchTerm,
    [Parameter()][ValidateSet("asset", "stock", "bulkItem")][string]$resourceCategory
  )  
  $endpoint = "/tas/api/assetmgmt/fields"
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If searchTerm is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("searchTerm")) { $uriparts.add("searchTerm=$($searchTerm)") }    
  # If lastSeenName is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("resourceCategory")) { $uriparts.add("resourceCategory=$($resourceCategory)") }   
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
  # Array to hold results from the API call
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.dataSet.Count) results."
    # Load results into an array
    foreach($item in $results.Results.dataSet){
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return $data  
}
#EndRegion '.\Public\Get-TopdeskAssetFields.ps1' 41
#Region '.\Public\Get-TopdeskAssetTemplates.ps1' 0
<#
  .DESCRIPTION
  This will return the list of asset templates for the topdesk platform.
  .PARAMETER archived
  Whether to show archived templates. Leave out for all, or specify true/false for only archived, or only active templates, respectively.
  .PARAMETER includeNonReadable
  Whether to show templates for assets which the user doesn't have read permission for. If this parameter isn't specified the endpoint returns templates for assets which the user has read permission for.
  .PARAMETER resourceCategory
  The endpoint returns templates matching the specified category only.
  .PARAMETER searchTerm
  The endpoint returns those templates which contain the given searchTerm in their name. It's case insensitive.
  .EXAMPLE
#>
function Get-TopdeskAssetTemplates{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter()][bool]$archived,
    [Parameter()][bool]$includeNonReadable,
    [Parameter()][ValidateSet("asset","stock","bulkItem")][string]$resourceCategory,
    [Parameter()][string][ValidateNotNullOrEmpty()]$searchTerm
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/assetmgmt/templates"
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If archived is not null, then set to how we want to see
  if($PSBoundParameters.ContainsKey("archived")){
    $uriparts.add("archived=$($archived)")
  }  
  # If includeNonReadable is not null, then set to how we want to see
  if($PSBoundParameters.ContainsKey("includeNonReadable")){
    $uriparts.add("includeNonReadable=$($includeNonReadable)")
  }  
  # If resourceCategory is not null, then set to how we want to see
  if($PSBoundParameters.ContainsKey("resourceCategory")){
    $uriparts.add("resourceCategory=$($resourceCategory)")
  }   
  # If searchTerm is not null, then add to URI parts
  if($PSBoundParameters.ContainsKey("searchTerm")){
    $uriparts.add("searchTerm=$($searchTerm)")
  }
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"
  # Array to hold results from the API call
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.dataSet.Count) results."
    # Load results into an array
    foreach($item in $results.Results.dataSet){
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return $data
}
#EndRegion '.\Public\Get-TopdeskAssetTemplates.ps1' 61
#Region '.\Public\Get-TopdeskAssetUpload.ps1' 0
<#
  .DESCRIPTION
  This will get a list of all the attachments that are associated with an asset, if the downloadpath is passed, it will also download the files.
  .PARAMETER assetId
  The ID of the asset, which contains the files. This is required
  .PARAMETER downloadPath
  The folder where we will save the files.
#>
function Get-TopdeskAssetUpload {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$assetId,
    [Parameter()][ValidateNotNullOrEmpty()][string]$downloadPath
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/assetmgmt/uploads?assetId=$($assetid)"
  try {
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    if ($PSBoundParameters.ContainsKey("downloadPath")) {
      foreach($file in $results.Results.dataset){
        $weburl = "$($file.url -replace "/tas/api/")"
        $filename = Join-Path $downloadPath -ChildPath $file.name
        Get-TopdeskAPIResponse -endpoint $weburl -downloadFile $filename | Out-Null
      }
    }
  }
  catch {
    throw $_
  }
  return $results.Results.dataset
}
#EndRegion '.\Public\Get-TopdeskAssetUpload.ps1' 32
#Region '.\Public\Get-TopdeskBranches.ps1' 0
function Get-TopdeskBranches{
  [CmdletBinding()]
  param(
    [Parameter()][string]$fields,
    [Parameter()][string]$id,
    [Parameter()][string]$startsWith,
    [Parameter()][string]$query,
    [Parameter()][string]$clientReferenceNumber
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/branches"
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()  
  # Create a list of the query parts that we would add the to the endpoint
  $queryparts = [System.Collections.Generic.List[PSCustomObject]]@()    
  # If id is not null, then set to how we want to see
  if($PSBoundParameters.ContainsKey("id")){
    $endpoint = "$($endpoint)/id/$($id)"
  }  
  # For backwards compat, allow to send specific query items that are common
  # If startswith is sent
  if($PSBoundParameters.ContainsKey("startsWith")){
    $queryparts.add("name=sw=$($startsWith)")
  }
  # If clientReferenceNumber is sent
  if($PSBoundParameters.ContainsKey("clientReferenceNumber")){
    $queryparts.add("clientReferenceNumber=sw=$($clientReferenceNumber)")
  }   
  # If query is not null, then set to how we want to see
  if($PSBoundParameters.ContainsKey("query") -or $queryparts.count -gt 0){
    $queryparts.add($query)
    $query = ($queryparts -join ";") -replace ".{1}$"
    $uriparts.add("query=$($query)")
  }
  # If fields is not null, then set to how we want to see
  if($PSBoundParameters.ContainsKey("fields")){
    $uriparts.add("`$fields=$($fields)")
  }    
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"
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
#EndRegion '.\Public\Get-TopdeskBranches.ps1' 57
#Region '.\Public\Get-TopdeskCategories.ps1' 0
function Get-TopdeskCategories{
  [CmdletBinding()]
  param( 
    [Parameter()][ValidateNotNullOrEmpty()][string]$fields, 
    [Parameter()][ValidateNotNullOrEmpty()][string]$query, 
    [Parameter()][ValidateNotNullOrEmpty()][string]$sort, 
    [Parameter()][switch]$pretty 
  )
  $endpoint = "/tas/api/categories"  
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  if($PSBoundParameters.ContainsKey("fields")){
    $uriparts.add("fields=$($fields)")
  }   
  if($PSBoundParameters.ContainsKey("query")){
    $uriparts.add("query=$($query)")
  }  
  if($PSBoundParameters.ContainsKey("sort")){
    $uriparts.add("sort=$($sort)")
  }  
  if($PSBoundParameters.ContainsKey("pretty")){
    $uriparts.add("pretty=$($pretty.IsPresent)")
  }     
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"
  # Array to hold results from the API call
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.results.item.count) results."
    # Load results into an array
    foreach($item in $results.results.item){
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return $data             
}
#EndRegion '.\Public\Get-TopdeskCategories.ps1' 42
#Region '.\Public\Get-TopdeskCurrency.ps1' 0
function Get-TopdeskCurrency{
  [CmdletBinding()]
  param()
  $endpoint = "/tas/api/currency"
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
#EndRegion '.\Public\Get-TopdeskCurrency.ps1' 20
#Region '.\Public\Get-TopdeskIncident.ps1' 0
<#
  .DESCRIPTION
  
  .PARAMETER id
  The ID of the incident
  .PARAMETER number
  The incident number
  .PARAMETER pageStart
  The offset to start at. The default is 0.
  .PARAMETER pageSize
  How many incidents should be returned max. Default is 10.
  .PARAMETER sort
  The sort order of the returned incidents. Incidents can be ordered by most of the fields. But for best performance one should order by one of the following fields: callDate, creationDate, modificationDate, targetDate, closedDate or id. It's faster to order by 1 field only. To specify if the order should be ascending or descending, append ":asc" or ":desc" to the field name. Multiple columns can be specified by comma-joining the orderings. Example: sort=tragetDate:asc,creationDate:desc. Fields not allowed for sorting are: externalLinks, escalationStatus, action, attachments, partialIncidents, partialIncidents.link
  .PARAMETER query
  A FIQL string to select which incidents should be returned. (See https://developers.topdesk.com/tutorial.html#query)
  .PARAMETER fields
  A comma-separated list of which fields should be returned. By default all fields will be returned. (slow)
  .PARAMETER dateFormat
  Format of date fields in json. When set to iso8601 dates will be sent in the form of '2020-10-01T14:10:00Z'. Otherwise old date format will be used: '2020-10-01T14:10:00.000+0000'
  .PARAMETER alltypes
  when present or when present and set to true will make all incident to be returned. Including partials and archived. This overrides the default behaviour when only firstLine and secondLine incidents are returned by default. This can be used in combinations with query parameter to narrow down the requited statuses.
  .PARAMETER all
  when present will make all incidents to be returned, looping over return of code 206 partial content

#>
function Get-TopdeskIncident {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter()][string][ValidateNotNullOrEmpty()]$id,
    [Parameter()][string][ValidateNotNullOrEmpty()]$number,
    [Parameter()][int][ValidateNotNullOrEmpty()]$pageStart = 0,
    [Parameter()][int][ValidateRange(1, 10000)]$pageSize = 10,
    [Parameter()][string][ValidateNotNullOrEmpty()]$sort,
    [Parameter()][string][ValidateNotNullOrEmpty()]$query,
    [Parameter()][string][ValidateNotNullOrEmpty()]$fields,
    [Parameter()][switch]$dateFormat,
    [Parameter()][switch]$alltypes,
    [Parameter()][switch]$all
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/incidents"
  # Check if we are getting a specific incident or query against all incidents
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)"
  }
  elseif ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)"
  }
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If pageSize is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("pageSize")) { $uriparts.add("pageSize=$($pageSize)") } 
  # If sort is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("sort")) { $uriparts.add("sort=$($sort)") } 
  # If query is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("query")) { $uriparts.add("query=$($query)") } 
  # If fields is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("fields")) { $uriparts.add("fields=$($fields)") } 
  # If dateFormat is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("dateFormat")) { $uriparts.add("dateFormat=iso8601") }
  # If alltypes is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("alltypes")) { $uriparts.add("all=$($alltypes.IsPresent)") }  
  # Add page start
  $uriparts.add("pageStart=$($pageStart)")
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"
  try {
    # Array to hold results from the API call
    $data = [System.Collections.Generic.List[PSObject]]@()
    $uri = $endpoint
    do {
      # Execute API Call
      $results = Get-TopdeskAPIResponse -endpoint $uri -Verbose:$VerbosePreference
      # Load results into an array
      foreach ($item in $results.Results) {
        $data.Add($item) | Out-Null
      }
      $pagestart += $pageSize
      Write-Verbose "Returned $($results.Results.Count) results. Current result set is $($data.Count) items."      
      $uri = $uri -replace "pageStart=\d*", "pageStart=$($pagestart)"
    }
    while ($all.IsPresent -and $results.StatusCode -eq 206)
  }
  catch {
    throw $_
  }  
  return $data
}
#EndRegion '.\Public\Get-TopdeskIncident.ps1' 90
#Region '.\Public\Get-TopdeskIncidentActions.ps1' 0
function Get-TopdeskIncidentActions{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "id")][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true, ParameterSetName = "number")][ValidateNotNullOrEmpty()][string]$number,
    [Parameter()][ValidateNotNullOrEmpty()][string]$actionid,
    [Parameter()][int][ValidateNotNullOrEmpty()]$Start = 0,
    [Parameter()][int][ValidateRange(1, 100)]$page_Size = 10, 
    [Parameter()][switch]$inlineimages,
    [Parameter()][switch]$non_api_attachment_urls,    
    [Parameter()][switch]$all
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/actions"
  }
  if ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/actions"
  }
  if ($PSBoundParameters.ContainsKey("actionid")) {
    $endpoint = "$($endpoint)/$($actionid)"
  }
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If pageSize is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("pageSize")) { $uriparts.add("pageSize=$($page_Size)") } 
  # If sort is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("inlineimages")) { $uriparts.add("inlineimages=$($inlineimages.IsPresent)") } 
  # If query is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("non_api_attachment_urls")) { $uriparts.add("non_api_attachment_urls=$($non_api_attachment_urls.IsPresent)") } 
  # Add page start
  $uriparts.add("start=$($start)")
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"
  try {
    # Array to hold results from the API call
    $data = [System.Collections.Generic.List[PSObject]]@()
    $uri = $endpoint
    do {
      # Execute API Call
      $results = Get-TopdeskAPIResponse -endpoint $uri -Verbose:$VerbosePreference
      # Load results into an array
      foreach ($item in $results.results) {
        $data.Add($item) | Out-Null
      }
      $start += $page_size
      Write-Verbose "Returned $($results.Results.Count) results. Current result set is $($data.Count) items."      
      $uri = $uri -replace "start=\d*", "start=$($start)"
    }
    while ($all.IsPresent -and $results.StatusCode -eq 206)
  }
  catch {
    throw $_
  }  
  return $data 
}
#EndRegion '.\Public\Get-TopdeskIncidentActions.ps1' 57
#Region '.\Public\Get-TopdeskIncidentAttachmentDownload.ps1' 0
function Get-TopdeskIncidentAttachmentDownload{
  [CmdletBinding()]
  param(  
    [Alias("incidentid")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$attachmentid,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$downloadFile
  )
  $endpoint = "/tas/api/incidents/id/$($id)/attachments/$($attachmentid)/download"
  try {
    Get-TopdeskAPIResponse -endpoint $endpoint -downloadFile $downloadFile -Verbose:$VerbosePreference | Out-Null
  }
  catch {
    throw $_
  }    
}
#EndRegion '.\Public\Get-TopdeskIncidentAttachmentDownload.ps1' 16
#Region '.\Public\Get-TopdeskIncidentAttachments.ps1' 0
function Get-TopdeskIncidentAttachments{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Alias("incidentid")][Parameter(Mandatory = $true, ParameterSetName = "id")][ValidateNotNullOrEmpty()][string]$id,
    [Alias("incidentnumber")][Parameter(Mandatory = $true, ParameterSetName = "number")][ValidateNotNullOrEmpty()][string]$number,
    [Parameter()][int][ValidateNotNullOrEmpty()]$Start = 0,
    [Parameter()][int][ValidateRange(1, 10)]$page_Size = 10, 
    [Parameter()][switch]$non_api_attachment_urls,    
    [Parameter()][switch]$all
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/attachments"
  }
  if ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/attachments"
  }  
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If pageSize is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("pageSize")) { $uriparts.add("pageSize=$($page_Size)") } 
  # If query is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("non_api_attachment_urls")) { $uriparts.add("non_api_attachment_urls=$($non_api_attachment_urls.IsPresent)") } 
  # Add page start
  $uriparts.add("start=$($start)")
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
  try {
    # Array to hold results from the API call
    $data = [System.Collections.Generic.List[PSObject]]@()
    $uri = $endpoint
    do {
      # Execute API Call
      $results = Get-TopdeskAPIResponse -endpoint $uri -Verbose:$VerbosePreference
      # Load results into an array
      foreach ($item in $results.results) {
        $data.Add($item) | Out-Null
      }
      $start += $page_size
      Write-Verbose "Returned $($results.Results.Count) results. Current result set is $($data.Count) items."      
      $uri = $uri -replace "start=\d*", "start=$($start)"
    }
    while ($all.IsPresent -and $results.StatusCode -eq 206)
  }
  catch {
    throw $_
  }  
  return $data 
}
#EndRegion '.\Public\Get-TopdeskIncidentAttachments.ps1' 50
#Region '.\Public\Get-TopdeskIncidentCallTypes.ps1' 0
function Get-TopdeskIncidentCallTypes{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
  )
  $endpoint = "/tas/api/incidents/call_types"
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
#EndRegion '.\Public\Get-TopdeskIncidentCallTypes.ps1' 22
#Region '.\Public\Get-TopdeskIncidentCategory.ps1' 0
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
#EndRegion '.\Public\Get-TopdeskIncidentCategory.ps1' 28
#Region '.\Public\Get-TopdeskIncidentClosureCodes.ps1' 0
function Get-TopdeskIncidentClosureCodes{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
  )
  $endpoint = "/tas/api/incidents/closure_codes"
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
#EndRegion '.\Public\Get-TopdeskIncidentClosureCodes.ps1' 22
#Region '.\Public\Get-TopdeskIncidentDeescalationReasons.ps1' 0
function Get-TopdeskIncidentDeescalationReasons{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
  )
  $endpoint = "/tas/api/incidents/deescalation-reasons"
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
#EndRegion '.\Public\Get-TopdeskIncidentDeescalationReasons.ps1' 22
#Region '.\Public\Get-TopdeskIncidentDurations.ps1' 0
function Get-TopdeskIncidentDurations{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
  )
  $endpoint = "/tas/api/incidents/durations"
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
#EndRegion '.\Public\Get-TopdeskIncidentDurations.ps1' 22
#Region '.\Public\Get-TopdeskIncidentEntryTypes.ps1' 0
function Get-TopdeskIncidentEntryTypes{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
  )
  $endpoint = "/tas/api/incidents/entry_types"
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
#EndRegion '.\Public\Get-TopdeskIncidentEntryTypes.ps1' 22
#Region '.\Public\Get-TopdeskIncidentEscalationReasons.ps1' 0
function Get-TopdeskIncidentEscalationReasons{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
  )
  $endpoint = "/tas/api/incidents/escalation-reasons"
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
#EndRegion '.\Public\Get-TopdeskIncidentEscalationReasons.ps1' 22
#Region '.\Public\Get-TopdeskIncidentImpacts.ps1' 0
function Get-TopdeskIncidentImpacts{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
  )
  $endpoint = "/tas/api/incidents/impacts"
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
#EndRegion '.\Public\Get-TopdeskIncidentImpacts.ps1' 22
#Region '.\Public\Get-TopdeskIncidentPriorities.ps1' 0
function Get-TopdeskIncidentPriorities{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
  )
  $endpoint = "/tas/api/incidents/priorities"
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
#EndRegion '.\Public\Get-TopdeskIncidentPriorities.ps1' 22
#Region '.\Public\Get-TopdeskIncidentProgressTrail.ps1' 0
function Get-TopdeskIncidentProgressTrail{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "id")]
    [Parameter(Mandatory = $true, ParameterSetName = "countid")]
      [string][ValidateNotNullOrEmpty()]$id,
    [Parameter(Mandatory = $true, ParameterSetName = "number")]
    [Parameter(Mandatory = $true, ParameterSetName = "countnumber")]
      [string][ValidateNotNullOrEmpty()]$number,
    [Parameter()][int][ValidateNotNullOrEmpty()]$Start = 0,
    [Parameter()][int][ValidateRange(1, 100)]$page_Size = 10, 
    [Parameter()][switch]$inlineimages,
    [Parameter()][switch]$non_api_attachment_urls,
    [Parameter(Mandatory = $true, ParameterSetName = "countid")]
    [Parameter(Mandatory = $true, ParameterSetName = "countnumber")]
      [switch]$count,
    [Parameter()][switch]$all
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/progresstrail"
  }
  if ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/progresstrail"
  }
  if ($PSBoundParameters.ContainsKey("count")) {
    $endpoint = "$($endpoint)/count"
  }
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If pageSize is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("pageSize")) { $uriparts.add("pageSize=$($page_Size)") } 
  # If sort is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("inlineimages")) { $uriparts.add("inlineimages=$($inlineimages.IsPresent)") } 
  # If query is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("non_api_attachment_urls")) { $uriparts.add("non_api_attachment_urls=$($non_api_attachment_urls.IsPresent)") } 
  # Add page start
  $uriparts.add("start=$($start)")
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"
  try {
    # Array to hold results from the API call
    $data = [System.Collections.Generic.List[PSObject]]@()
    $uri = $endpoint
    do {
      # Execute API Call
      $results = Get-TopdeskAPIResponse -endpoint $uri -Verbose:$VerbosePreference
      # Load results into an array
      foreach ($item in $results.results) {
        $data.Add($item) | Out-Null
      }
      $start += $page_size
      Write-Verbose "Returned $($results.Results.Count) results. Current result set is $($data.Count) items."      
      $uri = $uri -replace "start=\d*", "start=$($start)"
    }
    while ($all.IsPresent -and $results.StatusCode -eq 206)
  }
  catch {
    throw $_
  }  
  return $data 
}
#EndRegion '.\Public\Get-TopdeskIncidentProgressTrail.ps1' 63
#Region '.\Public\Get-TopdeskIncidentRequests.ps1' 0
function Get-TopdeskIncidentRequests{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "id")][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true, ParameterSetName = "number")][ValidateNotNullOrEmpty()][string]$number,
    [Parameter()][ValidateNotNullOrEmpty()][string]$requestid,
    [Parameter()][int][ValidateNotNullOrEmpty()]$Start = 0,
    [Parameter()][int][ValidateRange(1, 100)]$page_Size = 10, 
    [Parameter()][switch]$inlineimages,
    [Parameter()][switch]$non_api_attachment_urls,    
    [Parameter()][switch]$all
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/requests"
  }
  if ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/requests"
  }
  if ($PSBoundParameters.ContainsKey("requestid")) {
    $endpoint = "$($endpoint)/$($requestid)"
  }
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If pageSize is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("pageSize")) { $uriparts.add("pageSize=$($page_Size)") } 
  # If sort is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("inlineimages")) { $uriparts.add("inlineimages=$($inlineimages.IsPresent)") } 
  # If query is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("non_api_attachment_urls")) { $uriparts.add("non_api_attachment_urls=$($non_api_attachment_urls.IsPresent)") } 
  # Add page start
  $uriparts.add("start=$($start)")
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"
  try {
    # Array to hold results from the API call
    $data = [System.Collections.Generic.List[PSObject]]@()
    $uri = $endpoint
    do {
      # Execute API Call
      $results = Get-TopdeskAPIResponse -endpoint $uri -Verbose:$VerbosePreference
      # Load results into an array
      foreach ($item in $results.results) {
        $data.Add($item) | Out-Null
      }
      $start += $page_size
      Write-Verbose "Returned $($results.Results.Count) results. Current result set is $($data.Count) items."      
      $uri = $uri -replace "start=\d*", "start=$($start)"
    }
    while ($all.IsPresent -and $results.StatusCode -eq 206)
  }
  catch {
    throw $_
  }  
  return $data 
}
#EndRegion '.\Public\Get-TopdeskIncidentRequests.ps1' 57
#Region '.\Public\Get-TopdeskIncidentSearchList.ps1' 0
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
#EndRegion '.\Public\Get-TopdeskIncidentSearchList.ps1' 44
#Region '.\Public\Get-TopdeskIncidentServices.ps1' 0
function Get-TopdeskIncidentServices{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
  )
  $endpoint = "/tas/api/incidents/slas/services"
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
#EndRegion '.\Public\Get-TopdeskIncidentServices.ps1' 22
#Region '.\Public\Get-TopdeskIncidentSLAS.ps1' 0
function Get-TopdeskIncidentSLAS{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter()][int][ValidateRange(1, 10000)]$pageSize = 10,
    [Parameter()][string][ValidateNotNullOrEmpty()]$incident,
    [Parameter()][string][ValidateNotNullOrEmpty()]$contract,
    [Parameter()][string][ValidateNotNullOrEmpty()]$person,
    [Parameter()][string][ValidateNotNullOrEmpty()]$service,
    [Parameter()][string][ValidateNotNullOrEmpty()]$branch,
    [Parameter()][string][ValidateNotNullOrEmpty()]$budgetHolder,
    [Parameter()][string][ValidateNotNullOrEmpty()]$department,
    [Parameter()][string][ValidateNotNullOrEmpty()]$branchExtraA,
    [Parameter()][string][ValidateNotNullOrEmpty()]$branchExtraB,
    [Parameter()][datetime][ValidateNotNullOrEmpty()]$contractDate,
    [Parameter()][string][ValidateNotNullOrEmpty()]$callType,
    [Parameter()][string][ValidateNotNullOrEmpty()]$category,
    [Parameter()][string][ValidateNotNullOrEmpty()]$subcategory,
    [Parameter()][string][ValidateNotNullOrEmpty()]$asset
  )
  $endpoint = "/tas/api/incidents/slas"
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  $uriparts.add("pageSize=$($pageSize)")
  # If incident is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("incident")) { $uriparts.add("incident=$($incident)") } 
  # If contract is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("contract")) { $uriparts.add("contract=$($contract)") } 
  # If person is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("person")) { $uriparts.add("person=$($person)") } 
  # If service is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("service")) { $uriparts.add("service=$($service)") } 
  # If branch is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("branch")) { $uriparts.add("sort=$($branch)") } 
  # If budgetHolder is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("budgetHolder")) { $uriparts.add("budgetHolder=$($budgetHolder)") } 
  # If department is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("department")) { $uriparts.add("department=$($department)") } 
  # If branchExtraA is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("branchExtraA")) { $uriparts.add("branchExtraA=$($branchExtraA)") }      
  # If branchExtraB is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("branchExtraB")) { $uriparts.add("branchExtraB=$($branchExtraB)") }  
  # If contractDate is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("contractDate")) { $uriparts.add("contractDate=$($contractDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))") }  
  # If callType is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("callType")) { $uriparts.add("callType=$($callType)") }  
  # If category is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("category")) { $uriparts.add("category=$($category)") }  
  # If subcategory is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("subcategory")) { $uriparts.add("subcategory=$($subcategory)") }  
  # If asset is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("asset")) { $uriparts.add("asset=$($asset)") }
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.results.Count) results."
    # Load results into an array
    foreach($item in $results.Results.results){
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return $data   
}
#EndRegion '.\Public\Get-TopdeskIncidentSLAS.ps1' 70
#Region '.\Public\Get-TopdeskIncidentStatuses.ps1' 0
function Get-TopdeskIncidentStatuses{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
  )
  $endpoint = "/tas/api/incidents/statuses"
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
#EndRegion '.\Public\Get-TopdeskIncidentStatuses.ps1' 22
#Region '.\Public\Get-TopdeskIncidentSubcategories.ps1' 0
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
#EndRegion '.\Public\Get-TopdeskIncidentSubcategories.ps1' 32
#Region '.\Public\Get-TopdeskIncidentTimespent.ps1' 0
function Get-TopdeskIncidentTimespent{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "id")][string][ValidateNotNullOrEmpty()]$id,
    [Parameter(Mandatory = $true, ParameterSetName = "number")][string][ValidateNotNullOrEmpty()]$number   
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/timespent"
  }
  elseif ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/timespent"
  }
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    $process = $results.results | Where-Object {$_ -ne ""}
    Write-Verbose "Returned $($process.Count) results."
    # Load results into an array
    foreach($item in $process){
      $data.Add($item) | Out-Null
    } 
  } 
  catch{
    throw $_
  }  
  return $data
}
#EndRegion '.\Public\Get-TopdeskIncidentTimespent.ps1' 30
#Region '.\Public\Get-TopdeskIncidentUrgencies.ps1' 0
function Get-TopdeskIncidentUrgencies{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
  )
  $endpoint = "/tas/api/incidents/urgencies"
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
#EndRegion '.\Public\Get-TopdeskIncidentUrgencies.ps1' 22
#Region '.\Public\Get-TopdeskKnowledgeItem.ps1' 0
function Get-TopdeskKnowledgeItem{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter()][string]$id, 
    [Alias("page_size")][Parameter()][ValidateRange(1, 1000)][int]$pageSize = 100,
    [Alias("start")][Parameter()][int]$pageStart = 0,   
    [Parameter()][string]$fields, 
    [Parameter()][string]$query,
    [Parameter()][string]$language = "en-CA",
    [Parameter()][switch]$all
  )
  # The endpoint to get assets
  $endpoint = "/services/knowledge-base-v1/knowledgeItems"
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)"
  }
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If pageStart is not null, then add to URI parts
  $uriparts.add("start=$($pageStart)")
  # If pageSize is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("pageSize")) { $uriparts.add("page_size=$($pageSize)") }
  # If fields is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("fields")) { $uriparts.add("fields=$($fields)") } 
  # If query is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("query")) { $uriparts.add("query=$($query)") }     
  # If fields is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("language")) { $uriparts.add("language=$($language)") }   
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
  try {
    # Array to hold results from the API call
    $data = [System.Collections.Generic.List[PSObject]]@()
    $uri = $endpoint
    do {
      # Execute API Call
      $results = Get-TopdeskAPIResponse -endpoint $uri -Verbose:$VerbosePreference
      if($results.results.item.count -gt 0){
        $process = $results.results.item
      }
      else{
        $process = $results.results
      }
      # Load results into an array
      foreach ($item in $process) {
        $data.Add($item) | Out-Null
      }
      $pagestart += $pageSize
      Write-Verbose "Returned $($results.Results.item.Count) results. Current result set is $($data.Count) items."      
      $uri = $uri -replace "start=\d*", "start=$($pagestart)"
    }
    while ($all.IsPresent -and $results.StatusCode -eq 206)
  }
  catch {
    throw $_
  }  
  return $data
}
#EndRegion '.\Public\Get-TopdeskKnowledgeItem.ps1' 60
#Region '.\Public\Get-TopdeskKnowledgeItemAttachmentDownload.ps1' 0
function Get-TopdeskKnowledgeItemAttachmentDownload{
  [CmdletBinding()]
  param(  
    [Alias("incidentid")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$downloadFile,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$attachmentIdentifier
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/attachments/$($attachmentIdentifier)/download"
  try {
    Get-TopdeskAPIResponse -endpoint $endpoint -downloadFile $downloadFile -Verbose:$VerbosePreference | Out-Null
  }
  catch {
    throw $_
  }  
}
#EndRegion '.\Public\Get-TopdeskKnowledgeItemAttachmentDownload.ps1' 16
#Region '.\Public\Get-TopdeskKnowledgeItemAttachments.ps1' 0
function Get-TopdeskKnowledgeItemAttachments{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true, ParameterSetName = "id")][ValidateNotNullOrEmpty()][string]$id
  )
  # The endpoint to get assets
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/attachments"
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
#EndRegion '.\Public\Get-TopdeskKnowledgeItemAttachments.ps1' 25
#Region '.\Public\Get-TopdeskKnowledgeItemBranches.ps1' 0
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
#EndRegion '.\Public\Get-TopdeskKnowledgeItemBranches.ps1' 24
#Region '.\Public\Get-TopdeskKnowledgeItemImageDownload.ps1' 0
function Get-TopdeskKnowledgeItemImageDownload{
  [CmdletBinding()]
  param(  
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$imageName,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$downloadFile
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/images/$($imageName)/download"
  try {
    Get-TopdeskAPIResponse -endpoint $endpoint -downloadFile $downloadFile -Verbose:$VerbosePreference | Out-Null
  }
  catch {
    throw $_
  }   
}
#EndRegion '.\Public\Get-TopdeskKnowledgeItemImageDownload.ps1' 16
#Region '.\Public\Get-TopdeskKnowledgeItemImages.ps1' 0
function Get-TopdeskKnowledgeItemImages {
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][string]$id
  )
  # The endpoint to get assets
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/images"
  # Array to hold results from the API call
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.Count) results."
    # Load results into an array
    foreach($item in $results.Results){
      $data.Add([PSCustomObject]@{'Image' = $item}) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return $data        
}
#EndRegion '.\Public\Get-TopdeskKnowledgeItemImages.ps1' 25
#Region '.\Public\Get-TopdeskKnowledgeItemStatues.ps1' 0
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
#EndRegion '.\Public\Get-TopdeskKnowledgeItemStatues.ps1' 28
#Region '.\Public\Get-TopdeskLanguages.ps1' 0
function Get-TopdeskLanguages{
  [cmdletbinding()]
  param()
  $endpoint = "/tas/api/languages"
  $data = [System.Collections.Generic.List[PSObject]]@()
  try {
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.Count) results."
    # Load results into an array
    foreach ($item in $results.Results) {
      $data.Add($item) | Out-Null
    }    
  } 
  catch {
    throw $_
  }   
  return $data  
}
#EndRegion '.\Public\Get-TopdeskLanguages.ps1' 20
#Region '.\Public\Get-TopdeskOperatorChangeProgressTrail.ps1' 0
function Get-TopdeskOperatorChangeProgressTrail{
  [CmdletBinding()]
  [Alias("Get-TopdeskChangeProgress")]
  param(
    [Alias("changeID")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter()][switch]$inlineimages,
    [Parameter()][switch]$browserFriendlyUrls,
    [Parameter()][ValidateSet("memo", "attachment", "link","email")][string]$type
  )  
  $endpoint = "/tas/api/operatorChanges/$($id)/progresstrail"
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  ## If inlineimages is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("inlineimages")) { $uriparts.add("inlineimages=$($inlineimages.isPresent)") }    
  ## If browserFriendlyUrls is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("browserFriendlyUrls")) { $uriparts.add("browserFriendlyUrls=$($browserFriendlyUrls.isPresent)") }  
  ## If type is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("type")) { $uriparts.add("type=$($type)") }   
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
#EndRegion '.\Public\Get-TopdeskOperatorChangeProgressTrail.ps1' 37
#Region '.\Public\Get-TopdeskOperatorChanges.ps1' 0
function Get-TopdeskOperatorChanges{
  [CmdletBinding()]
  [Alias("Get-TopDeskChangeRequest")]
  param(
    [Parameter()][string]$id,
    [Parameter()][string]$query,
    [Parameter()][ValidateSet("id","creationDate","simple.closedDate","simple.plannedImplementationDate","simple.plannedStartDate","phases.rfc.plannedEndDate","phases.progress.plannedEndDate","phases.evaluation.plannedEndDate")][string]$sort,
    [Parameter()][ValidateSet("asc","desc")][string]$direction = "asc",
    [Parameter()][ValidateRange(1, 5000)][int]$pageSize = 1000,
    [Parameter()][int]$pageStart = 0,
    [Parameter()][string]$fields,
    [Parameter()][switch]$all
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/operatorChanges"
  # Check if we are getting a specific incident or query against all incidents
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/operatorChanges/$($id)"
  }
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If pageStart is not null, then add to URI parts
  $uriparts.add("pageStart=$($pageStart)")
  # If pageSize is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("pageSize")) { $uriparts.add("pageSize=$($pageSize)") }  
  # If query is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("query")) { $uriparts.add("query=$($query)") }   
  # If sort is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("sort")) { $uriparts.add("sort=$($sort):$($direction)") } 
  # If fields is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("fields")) { $uriparts.add("fields=$($fields)") } 
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"
  try {
    # Array to hold results from the API call
    $data = [System.Collections.Generic.List[PSObject]]@()
    $uri = $endpoint
    do {
      # Execute API Call
      $results = Get-TopdeskAPIResponse -endpoint $uri -Verbose:$VerbosePreference
      if($results.results.results.count -eq 0){
        $process = $results.results
      }
      else{
        $process = $results.results.results
      }
      # Load results into an array
      foreach ($item in $process) {
        $data.Add($item) | Out-Null
      }
      $pagestart += $pageSize
      Write-Verbose "Returned $($results.Results.Results.Count) results. Current result set is $($data.Count) items."      
      $uri = $uri -replace "pageStart=\d*", "pageStart=$($pagestart)"
    }
    while ($all.IsPresent -and $results.StatusCode -eq 206)
  }
  catch {
    throw $_
  }  
  return $data
}
#EndRegion '.\Public\Get-TopdeskOperatorChanges.ps1' 62
#Region '.\Public\Get-TopdeskOperatorChangesOrderedItems.ps1' 0
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
#EndRegion '.\Public\Get-TopdeskOperatorChangesOrderedItems.ps1' 25
#Region '.\Public\Get-TopdeskOperatorChangesRequests.ps1' 0
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
#EndRegion '.\Public\Get-TopdeskOperatorChangesRequests.ps1' 35
#Region '.\Public\Get-TopdeskOperatorGroups.ps1' 0
function Get-TopdeskOperatorGroups{
  [CmdletBinding()]
  [Alias("Get-TopdeskOperatorGroup")]
  param(
    [Parameter()][ValidateNotNullOrEmpty()][string]$id,
    [Parameter()][int]$start = 0,
    [Parameter()][ValidateRange(1, 100)][int]$page_size = 10,
    [Parameter()][ValidateNotNullOrEmpty()][string]$query,
    [Parameter()][ValidateNotNullOrEmpty()][string]$fields,
    [Parameter()][switch]$all
  )
  $endpoint = "/tas/api/operatorgroups"
  if ($PSBoundParameters.ContainsKey("id")){
    $endpoint = "/tas/api/operatorgroups/id/$($id)"
  }
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()    
  # If pageStart is not null, then add to URI parts
  $uriparts.add("start=$($start)")  
  # If pageSize is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("page_size")) { $uriparts.add("page_size=$($page_size)") }  
  # If query is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("query")) { $uriparts.add("query=$($query)") }   
  # If fields is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("fields")) { $uriparts.add("fields=$($fields)") }   
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
  try {
    # Array to hold results from the API call
    $data = [System.Collections.Generic.List[PSObject]]@()
    $uri = $endpoint
    do {
      # Execute API Call
      $results = Get-TopdeskAPIResponse -endpoint $uri -Verbose:$VerbosePreference
      # Load results into an array
      foreach ($item in $results.results) {
        $data.Add($item) | Out-Null
      }
      $start += $page_size
      Write-Verbose "Returned $($results.Results.Count) results. Current result set is $($data.Count) items."      
      $uri = $uri -replace "start=\d*", "start=$($start)"
    }
    while ($all.IsPresent -and $results.StatusCode -eq 206)
  }
  catch {
    throw $_
  }  
  return $data 
}
#EndRegion '.\Public\Get-TopdeskOperatorGroups.ps1' 50
#Region '.\Public\Get-TopdeskOperators.ps1' 0
function Get-TopdeskOperators{
  [CmdletBinding()]
  [Alias("Get-TopdeskOperator")]
  param(
    [Parameter()][int]$start = 0,
    [Parameter()][ValidateRange(1, 100)][int]$page_size = 10,
    [Parameter()][ValidateNotNullOrEmpty()][string]$query,
    [Parameter()][ValidateNotNullOrEmpty()][string]$fields,
    [Parameter()][switch]$all
  )
  $endpoint = "/tas/api/operators"
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()    
  # If pageStart is not null, then add to URI parts
  $uriparts.add("start=$($start)")  
  # If pageSize is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("page_size")) { $uriparts.add("page_size=$($page_size)") }  
  # If query is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("query")) { $uriparts.add("query=$($query)") }   
  # If fields is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("fields")) { $uriparts.add("fields=$($fields)") }   
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
  try {
    # Array to hold results from the API call
    $data = [System.Collections.Generic.List[PSObject]]@()
    $uri = $endpoint
    do {
      # Execute API Call
      $results = Get-TopdeskAPIResponse -endpoint $uri -Verbose:$VerbosePreference
      # Load results into an array
      foreach ($item in $results.results) {
        $data.Add($item) | Out-Null
      }
      $start += $page_size
      Write-Verbose "Returned $($results.Results.Count) results. Current result set is $($data.Count) items."      
      $uri = $uri -replace "start=\d*", "start=$($start)"
    }
    while ($all.IsPresent -and $results.StatusCode -eq 206)
  }
  catch {
    throw $_
  }  
  return $data 
}
#EndRegion '.\Public\Get-TopdeskOperators.ps1' 46
#Region '.\Public\Get-TopdeskPersons.ps1' 0
function Get-TopdeskPersons{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter()][string]$id,
    [Parameter()][int]$start = 0, 
    [Parameter()][ValidateRange(1, 5000)][int]$page_size = 10,
    [Parameter()][string]$fields,
    [Parameter()][string]$sort,
    [Parameter()][string]$query,
    [Parameter()][switch]$all
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/persons"
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "$($endpoint)/id/$($id)"
  }  
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()  
  # If pageStart is not null, then add to URI parts
  $uriparts.add("start=$($start)")  
  $uriparts.add("page_size=$($page_size)")  
  if ($PSBoundParameters.ContainsKey("fields")) { $uriparts.add("`$fields=$($fields)") }     
  if ($PSBoundParameters.ContainsKey("sort")) { $uriparts.add("sort=$($sort)") }     
  if ($PSBoundParameters.ContainsKey("query")) { $uriparts.add("query=$($query)") }     
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
  try {
    # Array to hold results from the API call
    $data = [System.Collections.Generic.List[PSObject]]@()
    $uri = $endpoint
    do {
      # Execute API Call
      $results = Get-TopdeskAPIResponse -endpoint $uri -Verbose:$VerbosePreference
      # Load results into an array
      foreach ($item in $results.results) {
        $data.Add($item) | Out-Null
      }
      $pagestart += $page_size
      Write-Verbose "Returned $($results.Results.item.Count) results. Current result set is $($data.Count) items."      
      $uri = $uri -replace "start=\d*", "start=$($pagestart)"
    }
    while ($all.IsPresent -and $results.StatusCode -eq 206)
  }
  catch {
    throw $_
  }  
  return $data   
}
#EndRegion '.\Public\Get-TopdeskPersons.ps1' 50
#Region '.\Public\Get-TopdeskPersonsAvatar.ps1' 0
function Get-TopdeskPersonsAvatar{
  [cmdletbinding()]
  param(
    [parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id
  )
  $endpoint = "/tas/api/persons/id/$($id)/avatar"
  # Execute API Call
  $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
  return $results.results
}
#EndRegion '.\Public\Get-TopdeskPersonsAvatar.ps1' 11
#Region '.\Public\Get-TopdeskPersonsContract.ps1' 0
function Get-TopdeskPersonsContract{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter(Mandatory = $true)][string]$id
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/persons/id/$($id)/contract"
  try {
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
  }
  catch {
    throw $_
  }  
  return $results.results
}
#EndRegion '.\Public\Get-TopdeskPersonsContract.ps1' 17
#Region '.\Public\Get-TopdeskPersonsCount.ps1' 0
function Get-TopdeskPersonsCount{
  [cmdletbinding()]
  [OutputType([int])]
  param(
    [Parameter()][string]$query
  ) 
  # The endpoint to get assets
  $endpoint = "/tas/api/persons/count"
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()   
  if ($PSBoundParameters.ContainsKey("query")) { $uriparts.add("query=$($query)") }   
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    # Load results into an array
    foreach($item in $results.Results){
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return  $results.Results.numberOfPersons   
}
#EndRegion '.\Public\Get-TopdeskPersonsCount.ps1' 28
#Region '.\Public\Get-TopdeskPersonsLookup.ps1' 0
function Get-TopdeskPersonsLookup{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter()][string]$id,
    [Parameter()][ValidateRange(1, 10000)][int]$top = 1000,
    [Parameter()][string]$name,
    [Parameter()][bool]$archived,
    [Parameter()][switch]$all
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/persons/lookup"
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "$($endpoint)/$($id)"
  }   
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  if ($PSBoundParameters.ContainsKey("top")) { $uriparts.add("`$top=$($top)") } 
  if ($PSBoundParameters.ContainsKey("name")) { $uriparts.add("name=$($name)") } 
  if ($PSBoundParameters.ContainsKey("archived")) { $uriparts.add("archived=$($archived)") } 
  if ($PSBoundParameters.ContainsKey("all")) { $uriparts.add("`$all=$($all.IsPresent)") } 
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    if($results.results.results.count -gt 0){
      $process = $results.results.results
    }
    else{
      $process = $results.results
    }    
    Write-Verbose "Returned $($process.count) results."
    # Load results into an array
    foreach($item in $process){
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return $data   
}
#EndRegion '.\Public\Get-TopdeskPersonsLookup.ps1' 45
#Region '.\Public\Get-TopdeskPersonsPrivateDetails.ps1' 0
function Get-TopdeskPersonsPrivateDetails{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter(Mandatory = $true)][string]$id
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/persons/id/$($id)/privateDetails"
  try {
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
  }
  catch {
    throw $_
  }  
  return $results.results
}
#EndRegion '.\Public\Get-TopdeskPersonsPrivateDetails.ps1' 17
#Region '.\Public\Get-TopdeskPersonsSearchList.ps1' 0
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
#EndRegion '.\Public\Get-TopdeskPersonsSearchList.ps1' 51
#Region '.\Public\Get-TopdeskProductVersion.ps1' 0
function Get-TopdeskProductVersion{
  [CmdletBinding()]
  param(  
  )
  $endpoint = "/tas/api/productVersion"  
  $data = [System.Collections.Generic.List[PSObject]]@()
  try {
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.Count) results."
    # Load results into an array
    foreach ($item in $results.Results) {
      $data.Add($item) | Out-Null
    }    
  } 
  catch {
    throw $_
  }   
  return $data       
}
#EndRegion '.\Public\Get-TopdeskProductVersion.ps1' 21
#Region '.\Public\Get-TopdeskRoleConfigurations.ps1' 0
function Get-TopdeskRoleConfigurations{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter()][string]$id
  )
  $endpoint = "/services/permissions/roleConfigurations"
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "$($endpoint)/$($id)"
  }  
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@() 
  if ($PSBoundParameters.ContainsKey("roleId")) { $uriparts.add("roleId=$($roleId -join ",")") } 
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    if($results.results._embedded.item){
      $process = $results.results._embedded.item
    }
    else{
      $process = $results.results
    }
    Write-Verbose "Returned $($process.Count) results."
    # Load results into an array
    foreach($item in $process){
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return $data     
}
#EndRegion '.\Public\Get-TopdeskRoleConfigurations.ps1' 37
#Region '.\Public\Get-TopdeskRoles.ps1' 0
function Get-TopdeskRoles{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter()][string]$id, 
    [Parameter()][bool]$archived,
    [Parameter()][bool]$licensed,
    [Parameter()][string]$fields
  )  
  $endpoint = "/services/permissions/roles"
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "$($endpoint)/$($id)"
  }
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()  
  if ($PSBoundParameters.ContainsKey("archived")) { $uriparts.add("archived=$($archived)") } 
  if ($PSBoundParameters.ContainsKey("licensed")) { $uriparts.add("licensed=$($licensed)") } 
  if ($PSBoundParameters.ContainsKey("fields")) { $uriparts.add("fields=$($fields)") } 
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    if($results.results._embedded.item){
      $process = $results.results._embedded.item
    }
    else{
      $process = $results.results
    }
    Write-Verbose "Returned $($process.Count) results."
    # Load results into an array
    foreach($item in $process){
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return $data      
}
#EndRegion '.\Public\Get-TopdeskRoles.ps1' 42
#Region '.\Public\Get-TopdeskServiceWindows.ps1' 0
function Get-TopdeskServiceWindows{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter()][ValidateNotNullOrEmpty()][string]$id,
    [Parameter()][int][ValidateRange(1, 10000)]$top = 1000, 
    [Parameter()][string][ValidateNotNullOrEmpty()]$name,
    [Parameter()][switch]$archived
  )  
  $endpoint = "/tas/api/serviceWindow/lookup/"
  if($PSBoundParameters.ContainsKey("id")){
    $endpoint = "$($endpoint)$($id)"
  }   
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  if($PSBoundParameters.ContainsKey("top")){
    $uriparts.add("`$top=$($top)")
  }      
  if($PSBoundParameters.ContainsKey("name")){
    $uriparts.add("name=$($name)")
  }
  if($PSBoundParameters.ContainsKey("archived")){
    $uriparts.add("archived=$($archived.IsPresent)")
  }
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"
  # Array to hold results from the API call
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    if($results.Results.Results.count -gt 0){
      $process = $results.Results.Results
    }
    else{
      $process = $results.Results
    }
    Write-Verbose "Returned $($process.Count) results."
    # Load results into an array
    foreach($item in $process){
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return $data        
}
#EndRegion '.\Public\Get-TopdeskServiceWindows.ps1' 49
#Region '.\Public\Get-TopdeskSupplierContacts.ps1' 0
function Get-TopdeskSupplierContacts{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter()][string]$id,
    [Parameter()][ValidateRange(1, 10000)][int]$page_size = 1000,
    [Parameter()][string]$query
  )  
  # The endpoint to get assets
  $endpoint = "/tas/api/supplierContacts"
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "$($endpoint)/$($id)"
  }  
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@() 
  $uriparts.add("page_size=$($pageSize)")  
  if ($PSBoundParameters.ContainsKey("query")) { $uriparts.add("query=$($query)") }
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
#EndRegion '.\Public\Get-TopdeskSupplierContacts.ps1' 34
#Region '.\Public\Get-TopdeskSuppliers.ps1' 0
function Get-TopdeskSuppliers{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter()][string]$id,
    [Alias("start")][Parameter()][int]$pageStart = 0, 
    [Alias("page_size")][Parameter()][ValidateRange(1, 100)][int]$pageSize = 10,
    [Parameter()][string]$query,
    [Parameter()][switch]$all
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/suppliers"
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "$($endpoint)/$($id)"
  }
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If pageStart is not null, then add to URI parts
  $uriparts.add("start=$($pageStart)")  
  $uriparts.add("page_size=$($pageSize)")  
  if ($PSBoundParameters.ContainsKey("query")) { $uriparts.add("query=$($query)") } 
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
  try {
    # Array to hold results from the API call
    $data = [System.Collections.Generic.List[PSObject]]@()
    $uri = $endpoint
    do {
      # Execute API Call
      $results = Get-TopdeskAPIResponse -endpoint $uri -Verbose:$VerbosePreference
      # Load results into an array
      foreach ($item in $results.results) {
        $data.Add($item) | Out-Null
      }
      $pagestart += $pageSize
      Write-Verbose "Returned $($results.Results.item.Count) results. Current result set is $($data.Count) items."      
      $uri = $uri -replace "start=\d*", "start=$($pagestart)"
    }
    while ($all.IsPresent -and $results.StatusCode -eq 206)
  }
  catch {
    throw $_
  }  
  return $data      
}
#EndRegion '.\Public\Get-TopdeskSuppliers.ps1' 46
#Region '.\Public\Get-TopdeskSuppliersLookup.ps1' 0
function Get-TopdeskSuppliersLookup{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter()][string]$id,
    [Parameter()][ValidateRange(1, 10000)][int]$top = 1000,
    [Parameter()][string]$name,
    [Parameter()][bool]$archived,
    [Parameter()][switch]$all
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/suppliers/lookup"
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "$($endpoint)/$($id)"
  }   
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  if ($PSBoundParameters.ContainsKey("top")) { $uriparts.add("`$top=$($top)") } 
  if ($PSBoundParameters.ContainsKey("name")) { $uriparts.add("`$name=$($name)") } 
  if ($PSBoundParameters.ContainsKey("archived")) { $uriparts.add("archived=$($archived)") } 
  if ($PSBoundParameters.ContainsKey("all")) { $uriparts.add("`$all=$($all.IsPresent)") } 
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"  
  $data = [System.Collections.Generic.List[PSObject]]@()
  try{
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    if($results.results.results.count -gt 0){
      $process = $results.results.results
    }
    else{
      $process = $results.results
    }    
    Write-Verbose "Returned $($process.count) results."
    # Load results into an array
    foreach($item in $process){
      $data.Add($item) | Out-Null
    }    
  } 
  catch{
    throw $_
  }   
  return $data   
}
#EndRegion '.\Public\Get-TopdeskSuppliersLookup.ps1' 45
#Region '.\Public\Get-TopdeskTimeRegistrations.ps1' 0
function Get-TopdeskTimeRegistrations{
  [CmdletBinding(DefaultParameterSetName = "All")]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "id")][string][ValidateNotNullOrEmpty()]$id,
    [Alias("start")][Parameter()][int][ValidateNotNullOrEmpty()]$pageStart = 0,
    [Alias("page_size")][Parameter()][int][ValidateRange(1, 10000)]$pageSize = 100,
    [Parameter()][string][ValidateNotNullOrEmpty()]$query,
    [Parameter()][string][ValidateNotNullOrEmpty()]$fields,
    [Parameter()][switch]$all
  )
  $endpoint = "/tas/api/incidents/timeregistrations"
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "$($endpoint)/$($id)"
  }  
  # Create a list of the URI parts that we would add the to the endpoint
  $uriparts = [System.Collections.Generic.List[PSCustomObject]]@()
  # If pageSize is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("pageSize")) { $uriparts.add("pageSize=$($pageSize)") } 
  # If sort is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("sort")) { $uriparts.add("sort=$($sort)") } 
  # If query is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("query")) { $uriparts.add("query=$($query)") } 
  # If fields is not null, then add to URI parts
  if ($PSBoundParameters.ContainsKey("fields")) { $uriparts.add("fields=$($fields)") } 
  # Add page start
  $uriparts.add("pageStart=$($pageStart)")
  # Generate the final API endppoint URI
  $endpoint = "$($endpoint)?$($uriparts -join "&")"
  try {
    # Array to hold results from the API call
    $data = [System.Collections.Generic.List[PSObject]]@()
    $uri = $endpoint
    do {
      # Execute API Call
      $results = Get-TopdeskAPIResponse -endpoint $uri -Verbose:$VerbosePreference
      # Load results into an array
      foreach ($item in $results.Results.Results) {
        $data.Add($item) | Out-Null
      }
      $pagestart += $pageSize
      Write-Verbose "Returned $($results.Results.Results.Count) results. Current result set is $($data.Count) items."      
      $uri = $results.Results.next -replace $global:topdeskAPIEndpoint
    }
    while ($all.IsPresent -and $null -ne $results.Results.next)
  }
  catch {
    throw $_
  }  
  return $data
}
#EndRegion '.\Public\Get-TopdeskTimeRegistrations.ps1' 52
#Region '.\Public\Get-TopdeskTimespentReasons.ps1' 0
function Get-TopdeskTimespentReasons {
  [CmdletBinding()]
  param(  
  )
  $endpoint = "/tas/api/timespent-reasons"  
  $data = [System.Collections.Generic.List[PSObject]]@()
  try {
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.Count) results."
    # Load results into an array
    foreach ($item in $results.Results) {
      $data.Add($item) | Out-Null
    }    
  } 
  catch {
    throw $_
  }   
  return $data     
}  
#EndRegion '.\Public\Get-TopdeskTimespentReasons.ps1' 21
#Region '.\Public\Get-TopdeskVersion.ps1' 0
function Get-TopdeskVersion{
  [CmdletBinding()]
  param(  
  )
  $endpoint = "/tas/api/version"  
  $data = [System.Collections.Generic.List[PSObject]]@()
  try {
    # Execute API Call
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference
    Write-Verbose "Returned $($results.Results.Count) results."
    # Load results into an array
    foreach ($item in $results.Results) {
      $data.Add($item) | Out-Null
    }    
  } 
  catch {
    throw $_
  }   
  return $data       
}
#EndRegion '.\Public\Get-TopdeskVersion.ps1' 21
#Region '.\Public\New-TopdeskAssetImportUpload.ps1' 0
function New-TopdeskAssetImportUpload{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$filePath,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$fileName,
    [Parameter()][string]$TopdeskTenant
  )
  $endpoint = "/services/import-to-api-v1/api/sourceFiles?filename=$($fileName)"
  $header = $global:topdeskHeader.Clone()
  $header."Content-Type" = "application/octet-stream"
  try {
    Get-TopdeskAPIResponse -endpoint $endpoint -Method "PUT" -headers $header -filePath $filePath -Verbose:$VerbosePreference
  }
  catch{
    throw $_ 
  }
}
#EndRegion '.\Public\New-TopdeskAssetImportUpload.ps1' 18
#Region '.\Public\New-TopdeskAssetUpload.ps1' 0
function New-TopdeskAssetUpload{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$assetId,
    [Parameter(Mandatory = $true)][string]$uploadfile
  )
  $endpoint = "/tas/api/assetmgmt/uploads?assetId=$($assetid)"
  # Override the default header
  $header = $global:topdeskHeader.Clone()
  $header."content-type" = "multipart/form-data; boundary=BOUNDARY"
  $file = Get-Item $uploadfile
  $fileContentEncoded = [convert]::ToBase64String((get-content $file.FullName -AsByteStream -Raw))
  $body = @"
--BOUNDARY
Content-Disposition: form-data; name="file"; filename="$($file.Name)"
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: base64

$($fileContentEncoded)
--BOUNDARY--
"@
  Get-TopdeskAPIResponse -endpoint $endpoint -Method "Post" -headers $header -body $body -Verbose:$VerbosePreference
}
#EndRegion '.\Public\New-TopdeskAssetUpload.ps1' 24
#Region '.\Public\New-TopdeskHTMLtoPDF.ps1' 0
function New-TopdeskHTMLtoPDF {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$html,
    [Parameter(Mandatory = $true)][string]$downloadFile,
    [Parameter()][string]$format,
    [Parameter()][string]$margin_top,
    [Parameter()][string]$margin_bottom,
    [Parameter()][string]$margin_left,
    [Parameter()][string]$margin_right
  )
  $endpoint = "/services/pdf-generator-v1/convert/html"
  $pdf = @{
    html         = $html
    downloadFile = $downloadFile
  }
  if ($PSBoundParameters.ContainsKey("format")) {
    $pdf.Add("format", $format)
  }
  foreach ($item in ($PSBoundParameters.keys | Where-Object { $_ -like "margin*" })) {
    $pdf.add($item, (Get-Variable -Name $item).value)
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($pdf | ConvertTo-Json) -Verbose:$VerbosePreference -Method "post" -downloadFile $downloadFile  | Out-Null
  } 
  catch{
    throw $_
  }
}
#EndRegion '.\Public\New-TopdeskHTMLtoPDF.ps1' 31
#Region '.\Public\New-TopdeskIncident.ps1' 0
function New-TopdeskIncident{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = 'body')][PSCustomObject]$body,
    [Parameter(Mandatory = $true,ParameterSetName = 'registeredCaller')][ValidateNotNullOrEmpty()][string]$caller_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_branch_id,
    [Parameter(Mandatory = $true,ParameterSetName = 'nonregisteredCaller')][ValidateNotNullOrEmpty()][string]$caller_dynamicName,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_phoneNumber,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_mobileNumber,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_email,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_department_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_department_name,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_location_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_budgetHolder_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_budgetHolder_name,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_personExtraFieldA_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_personExtraFieldA_name,   
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_personExtraFieldB_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_personExtraFieldB_name,     
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_callerLookup_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$status,
    [Parameter()][ValidateNotNullOrEmpty()][string]$briefDescription,
    [Parameter()][ValidateNotNullOrEmpty()][string]$request,
    [Parameter()][ValidateNotNullOrEmpty()][string]$action,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$actionInvisibleForCaller,
    [Parameter()][ValidateNotNullOrEmpty()][string]$entryType_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$entryType_name,    
    [Parameter()][ValidateNotNullOrEmpty()][string]$callType_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$callType_name, 
    [Parameter()][ValidateNotNullOrEmpty()][string]$category_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$category_name,    
    [Parameter()][ValidateNotNullOrEmpty()][string]$subcategory_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$subcategory_name, 
    [Parameter()][ValidateNotNullOrEmpty()][string]$externalNumber,       
    [Parameter()][ValidateNotNullOrEmpty()][string]$object_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$object_name, 
    [Parameter()][ValidateNotNullOrEmpty()][string]$location_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$branch_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$mainIncident_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$mainIncident_number, 
    [Parameter()][ValidateNotNullOrEmpty()][string]$impact_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$impact_name, 
    [Parameter()][ValidateNotNullOrEmpty()][string]$urgency_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$urgency_name, 
    [Parameter()][ValidateNotNullOrEmpty()][string]$priority_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$priority_name, 
    [Parameter()][ValidateNotNullOrEmpty()][string]$duration_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$duration_name,    
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$targetDate,
    [Parameter()][ValidateNotNullOrEmpty()][string]$sla_id,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$onHold,
    [Parameter()][ValidateNotNullOrEmpty()][string]$operator_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$operatorGroup_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$supplier_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$processingStatus_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$processingStatus_name,  
    [Parameter()][ValidateNotNullOrEmpty()][bool]$responded,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$responseDate,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$completed,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$completedDate,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$closed,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$closedDate,
    [Parameter()][ValidateNotNullOrEmpty()][string]$closureCode_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$closureCode_name, 
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$costs,
    [Parameter()][ValidateNotNullOrEmpty()][int]$feedbackRating,
    [Parameter()][ValidateNotNullOrEmpty()][string]$feedbackMessage, 
    [Parameter()][ValidateNotNullOrEmpty()][bool]$majorCall,
    [Parameter()][ValidateNotNullOrEmpty()][string]$majorCallObject_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$majorCallObject_number, 
    [Parameter()][ValidateNotNullOrEmpty()][bool]$publishToSsd,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$optionalFields1_boolean1,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$optionalFields1_boolean2,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$optionalFields1_boolean3,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$optionalFields1_boolean4,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$optionalFields1_boolean5,
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$optionalFields1_number1,
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$optionalFields1_number2,
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$optionalFields1_number3,
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$optionalFields1_number4,
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$optionalFields1_number5,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_text1,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_text2,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_text3,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_text4,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_text5,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_memo1,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_memo2,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_memo3,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_memo4,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_memo5,    
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$optionalFields1_date1,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$optionalFields1_date2,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$optionalFields1_date3,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$optionalFields1_date4,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$optionalFields1_date5,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_searchlist1_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_searchlist1_name,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_searchlist2_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_searchlist2_name,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_searchlist3_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_searchlist3_name,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_searchlist4_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_searchlist4_name,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_searchlist5_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_searchlist5_name,                
    [Parameter()][ValidateNotNullOrEmpty()][bool]$optionalFields2_boolean1,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$optionalFields2_boolean2,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$optionalFields2_boolean3,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$optionalFields2_boolean4,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$optionalFields2_boolean5,
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$optionalFields2_number1,
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$optionalFields2_number2,
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$optionalFields2_number3,
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$optionalFields2_number4,
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$optionalFields2_number5,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_text1,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_text2,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_text3,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_text4,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_text5,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_memo1,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_memo2,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_memo3,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_memo4,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_memo5,    
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$optionalFields2_date1,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$optionalFields2_date2,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$optionalFields2_date3,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$optionalFields2_date4,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$optionalFields2_date5,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_searchlist1_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_searchlist1_name,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_searchlist2_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_searchlist2_name,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_searchlist3_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_searchlist3_name,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_searchlist4_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_searchlist4_name,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_searchlist5_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_searchlist5_name,      
    [Parameter()][ValidateNotNullOrEmpty()][string]$externalLink_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$externalLink_type,
    [Parameter()][ValidateNotNullOrEmpty()][string]$externalLink_date
  )
  $endpoint = "/tas/api/incidents"
  if (-not $PSBoundParameters.ContainsKey("body")) {
    $body = @{}
    foreach($item in $PsBoundParameters.GetEnumerator()){
      if($item.key -eq "Verbose"){continue}
      $key = $item.Key.split("_")
      if($key.count -gt 1){
        $parent = ""
        for($i = 0; $i -lt $key.count - 1; $i++){
          if($i -eq 0){
            if(!$body.ContainsKey($key[$i])){
              $body.Add($key[$i],@{}) | Out-Null
            }
            $parent = $key[$i]
          }
          else{
            $scriptBlock = "
              if(!`$body.$($parent).ContainsKey(`"$($key[$i])`")){
                `$body.$($parent).Add(`"$($key[$i])`",@{}) | Out-Null
              }
              `$parent = `"$($parent).$($key[$i])`"
            "
            Invoke-Expression $scriptBlock
          }
        }
        $scriptBlock = "
          `$body.$($parent).Add(`"$($key[$i])`",`$item.value)
        "
        Invoke-Expression $scriptBlock
      }
      else{
        if(!$body.ContainsKey($item.Key)){
          $body.Add($item.Key,$item.Value) | Out-Null
        }
      }
    }
  }
  try {
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Method "POST" -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference -AllowInsecureRedirect
    Write-Verbose "Created incident." 
  } 
  catch {
    throw $_
  } 
  return $results.results
}
#EndRegion '.\Public\New-TopdeskIncident.ps1' 192
#Region '.\Public\New-TopdeskIncidentAttachment.ps1' 0
function New-TopdeskIncidentAttachment{
  [CmdletBinding()]
  [Alias("Add-TopdeskIncidentAttachment")]
  param(
    [Alias("id")][Parameter(Mandatory = $true, ParameterSetName = "id")][ValidateNotNullOrEmpty()][string]$incidentId,
    [Parameter(Mandatory = $true, ParameterSetName = "number")][ValidateNotNullOrEmpty()][string]$incidentNumber,
    [Parameter()][switch]$non_api_attachment_urls,
    [Parameter()][ValidateNotNullOrEmpty()][string]$filepath,
    [Parameter()][ValidateNotNullOrEmpty()][string]$filename,
    [Parameter()][switch]$invisibleForCaller,
    [Parameter()][ValidateNotNullOrEmpty()][string]$description
  )
  if($PSBoundParameters.ContainsKey("incidentId")){
    $endpoint = "/tas/api/incidents/id/$($incidentid)/attachments"
  }
  elseif($PSBoundParameters.ContainsKey("incidentNumber")){
    $endpoint = "/tas/api/incidents/number/$($incidentNumber)/attachments"
  }
  $fileContentEncoded = [convert]::ToBase64String((get-content $filepath -AsByteStream -Raw))
  $header = $global:topdeskHeader.Clone()
  $header."content-type" = "multipart/form-data; boundary=BOUNDARY"

  $body = @"
--BOUNDARY
Content-Disposition: form-data; name="invisibleForCaller"

$($invisibleForCaller.IsPresent)
--BOUNDARY
Content-Disposition: form-data; name="description"

$($description) 
--BOUNDARY
Content-Disposition: form-data; name="file"; filename="$($filename)"
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: base64

$($fileContentEncoded)
--BOUNDARY--
"@
  try {
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Method "Post" -headers $header -body $body -Verbose:$VerbosePreference
  }
  catch {
    if ($_.Exception.Message -eq "Conflict") {
      Write-Output "Image already exists ($($imagename)). Skipping."
    }
    else {
      throw $_ 
    }     
  }
  return $results.Results
}
#EndRegion '.\Public\New-TopdeskIncidentAttachment.ps1' 53
#Region '.\Public\New-TopdeskKnowledgeItem.ps1' 0
function New-TopdeskKnowledgeItem {
  [cmdletbinding()]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = 'body')][PSCustomObject]$body,
    [Parameter(ParameterSetName = 'Title')][string]$parent,
    [Parameter(ParameterSetName = 'Title')][string]$language = "en-CA",
    [Parameter(Mandatory = $true, ParameterSetName = 'Title')][string]$title,
    [Parameter(ParameterSetName = 'Title')][string]$description,
    [Parameter(ParameterSetName = 'Title')][string]$content,
    [Parameter(ParameterSetName = 'Title')][string]$commentsForOperators,
    [Parameter(ParameterSetName = 'Title')][string]$keywords,
    [Parameter(ParameterSetName = 'Title')][ValidateSet("NOT_VISIBLE", "VISIBLE", "VISIBLE_IN_PERIOD")][string]$sspVisibility = "NOT_VISIBLE",
    [Parameter(ParameterSetName = 'Title')][datetime]$sspVisibleFrom,
    [Parameter(ParameterSetName = 'Title')][datetime]$sspVisibleUntil,
    [Parameter(ParameterSetName = 'Title')][bool]$sspVisibilityFilteredOnBranches = $false,
    [Parameter(ParameterSetName = 'Title')][bool]$operatorVisibilityFilteredOnBranches = $false,
    [Parameter(ParameterSetName = 'Title')][bool]$openKnowledgeItem = $false,
    [Parameter(ParameterSetName = 'Title')][string]$status,
    [Parameter(ParameterSetName = 'Title')][string]$manager,
    [Parameter(ParameterSetName = 'Title')][string]$externalLinkid,
    [Parameter(ParameterSetName = 'Title')][string]$externalLinktype,
    [Parameter(ParameterSetName = 'Title')][datetime]$externalLinkdate
  )  
  # The endpoint to get assets
  $endpoint = "/services/knowledge-base-v1/knowledgeItems"  
  if (-not $PSBoundParameters.ContainsKey("body")) {
    $body = @{
      parent       = @{
        number = $parent
      }
      translation  = @{
        language = $language
        content  = @{
          title                = $title
          description          = $description
          content              = $content
          commentsForOperators = $commentsForOperators
          keywords             = $keywords        
        }
      }
      visibility   = @{
        sspVisibility                        = $sspVisibility
        sspVisibleFrom                       = $sspVisibleFrom
        sspVisibleUntil                      = $sspVisibleUntil
        sspVisibilityFilteredOnBranches      = $sspVisibilityFilteredOnBranches
        operatorVisibilityFilteredOnBranches = $operatorVisibilityFilteredOnBranches
        openKnowledgeItem                    = $openKnowledgeItem
      }
      externalLink = @{
        id   = $externalLinkid
        type = $externalLinktype
        date = $externalLinkdate
      }
    }
    if ($PSBoundParameters.ContainsKey("status")) {
      $body.Add("status", @{id = $status}) | Out-Null
    }
    if ($PSBoundParameters.ContainsKey("manager")) {
      $body.Add("manager",@{id = $manager}) | Out-Null
    }
  }
  try {
    $header = $global:topdeskHeader.Clone()
    $header."content-type" = "application/x.topdesk-kb-create-ki-v1+json"
    Get-TopdeskAPIResponse -endpoint $endpoint -headers $header -Method "POST" -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference -AllowInsecureRedirect
    Write-Verbose "Created knowledgeitem." 
  } 
  catch {
    throw $_
  }   
}
#EndRegion '.\Public\New-TopdeskKnowledgeItem.ps1' 72
#Region '.\Public\New-TopdeskKnowledgeItemAttachment.ps1' 0
function New-TopdeskKnowledgeItemAttachment {
  [CmdletBinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$filepath,
    [Parameter()][ValidateNotNullOrEmpty()][string]$description
  )
  $endpoint = "/tas/api/knowledgeItems/$($id)/attachments"
  $header = $global:topdeskHeader.Clone()
  $header."content-type" = "multipart/form-data"
  $form = @{
    file = Get-Item $filepath
    description = $description
  }
  try{
    Get-TopdeskAPIResponse -endpoint $endpoint -Method Post -headers $header -form $form  -AllowInsecureRedirect -Verbose:$VerbosePreference | Out-Null
  }
  catch{
    throw $_
  } 
}
#EndRegion '.\Public\New-TopdeskKnowledgeItemAttachment.ps1' 22
#Region '.\Public\New-TopdeskKnowledgeItemImage.ps1' 0
function New-TopdeskKnowledgeItemImage {
  [cmdletbinding()]
  param(
    [Alias("id")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$identifier,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$filepath
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($identifier)/images"
  $header = $global:topdeskHeader.Clone()
  $header."content-type" = "multipart/form-data"
  $form = @{
    file = Get-Item $filepath
  }
  try{
    Get-TopdeskAPIResponse -endpoint $endpoint -Method Post -headers $header -form $form -AllowInsecureRedirect -Verbose:$VerbosePreference | Out-Null
  }
  catch{
    throw $_
  }
}
#EndRegion '.\Public\New-TopdeskKnowledgeItemImage.ps1' 20
#Region '.\Public\New-TopdeskKnowledgeItemStatues.ps1' 0
function New-TopdeskKnowledgeItemStatues{
  [cmdletbinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$name
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItemStatuses"
  $body = @{
    name = $name
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference -Method "POST" | Out-Null
  } 
  catch{
    throw $_
  }   
}
#EndRegion '.\Public\New-TopdeskKnowledgeItemStatues.ps1' 18
#Region '.\Public\New-TopdeskKnowledgeItemTranslation.ps1' 0
function New-TopdeskKnowledgeItemTranslation {
  [cmdletbinding()]
  param(
    [Alias("identifier")]
    [Parameter(Mandatory = $true, ParameterSetName = 'body')]
    [Parameter(Mandatory = $true, ParameterSetName = 'Title')]
    [ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true, ParameterSetName = 'body')][PSCustomObject]$body,
    [Parameter(ParameterSetName = 'Title')][string]$language = "en-CA",
    [Parameter(Mandatory = $true, ParameterSetName = 'Title')][string]$title,
    [Parameter(ParameterSetName = 'Title')][string]$description,
    [Parameter(ParameterSetName = 'Title')][string]$content,
    [Parameter(ParameterSetName = 'Title')][string]$commentsForOperators,
    [Parameter(ParameterSetName = 'Title')][string]$keywords
  )  
  # The endpoint to get assets
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/translations"     
  if (-not $PSBoundParameters.ContainsKey("body")) {
    $body = @{
      language = $language
      content  = @{
        title                = $title
        description          = $description
        content              = $content
        commentsForOperators = $commentsForOperators
        keywords             = $keywords        
      }      
    }
  }
  try {
    $header = $global:topdeskHeader.Clone()
    $header."content-type" = "application/x.topdesk-kb-create-translation-v1+json"
    Get-TopdeskAPIResponse -endpoint $endpoint -headers $header -Method "POST" -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference -AllowInsecureRedirect
    Write-Verbose "Created knowledgeitem translation." 
  } 
  catch {
    throw $_
  }   
}
#EndRegion '.\Public\New-TopdeskKnowledgeItemTranslation.ps1' 40
#Region '.\Public\New-TopdeskQR.ps1' 0
function New-TopdeskQR{
  [CmdletBinding()]
  param(
    [Parameter()][string]$format = "QR_CODE",
    [Parameter()][int]$width = 400,
    [Parameter()][int]$height = 400,
    [Parameter()][string]$imageType = "PNG",
    [Parameter(Mandatory = $true)][string]$text,
    [Parameter()][string]$header,
    [Parameter()][string]$footer,
    [Parameter(Mandatory = $true)][string]$downloadFile
  )
  $endpoint = "/solutions/multi-barcode-creator-1/qr"
  $body = @{
    metadata = @{
      format = $format
      width = $width
      height = $height
      imageType = $imageType
    }
    content = @{
      text = $text
    }
  }
  if ($PSBoundParameters.ContainsKey("header")) {
    $body.content.Add("header", $header)
  }
  if ($PSBoundParameters.ContainsKey("footer")) {
    $body.content.Add("footer", $footer)
  }   
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($body | ConvertTo-Json) -Verbose:$VerbosePreference -Method "post" -downloadFile $downloadFile  | Out-Null
  } 
  catch{
    throw $_
  }   
}
#EndRegion '.\Public\New-TopdeskQR.ps1' 39
#Region '.\Public\New-TopdeskTaskNotification.ps1' 0
function New-TopdeskTaskNotification{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$title,
    [Parameter(Mandatory = $true)][string]$body,
    [Parameter()][string]$url,
    [Parameter()][string[]]$operatorIds,
    [Parameter()][string[]]$operatorGroupIds
  )  
  $endpoint = "/tas/api/tasknotifications/custom"
  $task = @{
    title = $title
    body = $body
  }
  if ($PSBoundParameters.ContainsKey("url")){
    $task.Add("url", $url) | Out-Null
  }  
  if ($PSBoundParameters.ContainsKey("operatorIds")){
    $task.Add("operatorIds", $operatorIds) | Out-Null
  }  
  if ($PSBoundParameters.ContainsKey("operatorGroupIds")){
    $task.Add("operatorGroupIds", $operatorGroupIds) | Out-Null
  }   
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($task | ConvertTo-Json) -Verbose:$VerbosePreference -Method "post" | Out-Null
  } 
  catch{
    throw $_
  } 
}
#EndRegion '.\Public\New-TopdeskTaskNotification.ps1' 32
#Region '.\Public\Remove-TopdeskAssetAssignments.ps1' 0
<#
  .DESCRIPTION
  
  .PARAMETER type
  Type of the linked entity
  .PARAMETER targetId
  Id of the linked entity.
  .PARAMETER assetids
  The ID of the asset
  .PARAMETER linkId
  The ID of the assignment
#>
function Remove-TopdeskAssetAssignments{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true,ParameterSetName = 'POST')][ValidateSet("branch", "location", "personGroup","person")][string]$type,
    [Parameter(Mandatory = $true,ParameterSetName = 'POST')][ValidateNotNullOrEmpty()][string]$targetId,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string[]]$assetids,
    [Parameter(Mandatory = $true,ParameterSetName = 'DELETE')][ValidateNotNullOrEmpty()][string]$linkId
  )
  $vars = @{
    Verbose = $VerbosePreference
  }
  switch($PSCmdlet.ParameterSetName){
    "POST" {
      $vars.Method = "POST"
      $vars.endpoint = "/tas/api/assetmgmt/assets/unlink/$($type)/$($targetId)"
      $vars.body = @{
        assetIds = $assetids
      } | ConvertTo-Json
    }
    "DELETE" {
      $vars.Method = "DELETE"
      $vars.endpoint = "/tas/api/assetmgmt/assets/$($assetids)/assignments/$($linkId)"
    }
  }
  try{
    $results = Get-TopdeskAPIResponse @vars
  }
  catch{
    throw $_
  }
  return $results.Results
}
#EndRegion '.\Public\Remove-TopdeskAssetAssignments.ps1' 46
#Region '.\Public\Remove-TopdeskAssetField.ps1' 0
<#
  .DESCRIPTION
  
  .PARAMETER fieldId
  Id of the field
#>
function Remove-TopdeskAssetField{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$fieldid
  )
  $endpoint = "/tas/api/assetmgmt/fields/$($fieldId)"
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference -Method "Delete" | Out-Null
    Write-Verbose "Deleted asset field with id $($fieldid) from system." 
  } 
  catch{
    throw $_
  }      
}
#EndRegion '.\Public\Remove-TopdeskAssetField.ps1' 22
#Region '.\Public\Remove-TopdeskAssetUpload.ps1' 0
function Remove-TopdeskAssetUpload{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$uploadId
  )
  $endpoint = "/tas/api/assetmgmt/uploads/$($uploadId)"
  try{
    Get-TopdeskAPIResponse -endpoint $endpoint -Method "Delete" -Verbose:$VerbosePreference
  }
  catch{
    throw $_
  }
}
#EndRegion '.\Public\Remove-TopdeskAssetUpload.ps1' 14
#Region '.\Public\Remove-TopdeskIncidentAction.ps1' 0
function Remove-TopdeskIncidentAction{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "id")][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true, ParameterSetName = "number")][ValidateNotNullOrEmpty()][string]$number,
    [Parameter(Mandatory = $true)][string]$actionid  
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/actions/$($actionid)"
  }
  if ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/actions/$($actionid)"
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference -Method "Delete" | Out-Null
    Write-Verbose "Deleted action entry with id $($actionid)." 
  } 
  catch{
    throw $_
  }    
}
#EndRegion '.\Public\Remove-TopdeskIncidentAction.ps1' 23
#Region '.\Public\Remove-TopdeskIncidentAttachment.ps1' 0
function Remove-TopdeskIncidentAttachment{
  [CmdletBinding()]
  param(  
    [Alias("incidentid")][Parameter(Mandatory = $true, ParameterSetName = "id")][ValidateNotNullOrEmpty()][string]$id,
    [Alias("incidentnumber")][Parameter(Mandatory = $true, ParameterSetName = "number")][ValidateNotNullOrEmpty()][string]$number,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$attachmentid
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/attachments/$($attachmentid)"
  }
  if ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/attachments/$($attachmentid)"
  }  
  try {
    Get-TopdeskAPIResponse -endpoint $endpoint -Method Delete -Verbose:$VerbosePreference | Out-Null
  }
  catch {
    throw $_
  }   
}
#EndRegion '.\Public\Remove-TopdeskIncidentAttachment.ps1' 21
#Region '.\Public\Remove-TopdeskIncidentRequest.ps1' 0
function Remove-TopdeskIncidentRequest{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "id")][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true, ParameterSetName = "number")][ValidateNotNullOrEmpty()][string]$number,
    [Parameter(Mandatory = $true)][string]$requestid  
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/requests/$($requestid)"
  }
  if ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/requests/$($requestid)"
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference -Method "Delete" | Out-Null
    Write-Verbose "Deleted action entry with id $($requestid)." 
  } 
  catch{
    throw $_
  }    
}
#EndRegion '.\Public\Remove-TopdeskIncidentRequest.ps1' 23
#Region '.\Public\Remove-TopdeskKnowledgeItemAtttachment.ps1' 0
function Remove-TopdeskKnowledgeItemAtttachment{
  [CmdletBinding()]
  param(  
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$attachmentIdentifier
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/attachments/$($attachmentIdentifier)"
  try {
    Get-TopdeskAPIResponse -endpoint $endpoint -Method Delete -Verbose:$VerbosePreference | Out-Null
  }
  catch {
    throw $_
  }   
}
#EndRegion '.\Public\Remove-TopdeskKnowledgeItemAtttachment.ps1' 15
#Region '.\Public\Remove-TopdeskKnowledgeItemBranchesLink.ps1' 0
function Remove-TopdeskKnowledgeItemBranchesLink{
  [cmdletbinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$branchid
  )
  # The endpoint to get assets
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/branches/unlink"
  $body = @{
    "id" = $branchid
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($body | ConvertTo-Json) -Verbose:$VerbosePreference -Method "post" | Out-Null
  } 
  catch{
    throw $_
  }
}
#EndRegion '.\Public\Remove-TopdeskKnowledgeItemBranchesLink.ps1' 20
#Region '.\Public\Remove-TopdeskKnowledgeItemImage.ps1' 0
function Remove-TopdeskKnowledgeItemImage {
  [cmdletbinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$imagename
  ) 
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/images/$($imagename)"
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference -Method "Delete" | Out-Null
    Write-Verbose "Deleted knowledge item image$($imagename) from KI $($id)." 
  } 
  catch{
    throw $_
  } 
}
#EndRegion '.\Public\Remove-TopdeskKnowledgeItemImage.ps1' 17
#Region '.\Public\Remove-TopdeskKnowledgeItemTranslation.ps1' 0
function Remove-TopdeskKnowledgeItemTranslation{
  [cmdletbinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true)][string]$language
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/translations/$($language)"
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference -Method "Delete" | Out-Null
    Write-Verbose "Deleted translation entry with language $($language)." 
  } 
  catch{
    throw $_
  }   
}
#EndRegion '.\Public\Remove-TopdeskKnowledgeItemTranslation.ps1' 17
#Region '.\Public\Send-TopdeskEmail.ps1' 0
function Send-TopdeskEmail {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][string]$from,
    [Parameter(Mandatory = $true)][string[]]$to,
    [Parameter()][string[]]$cc,
    [Parameter()][string[]]$bcc,
    [Parameter()][string]$replyTo,
    [Parameter(Mandatory = $true)][string]$subject,
    [Parameter(Mandatory = $true)][string]$body,
    [Parameter()][switch]$isHtmlBody,
    [Parameter()][int]$priority = 3,
    [Parameter()][switch]$requestDeliveryReceipt,
    [Parameter()][switch]$requestReadReceipt,
    [Parameter()][switch]$issuppressAutomaticReplies,
    [Parameter()][string]$attachments
  )
  $endpoint = "/services/email-v1/api/send"
  $mail = @{
    from                       = $from
    to                         = ($to -join ",")
    subject                    = $subject
    body                       = $body
    isHtmlBody                 = $isHtmlBody.IsPresent
    priority                   = $priority
    requestDeliveryReceipt     = $requestDeliveryReceipt.IsPresent
    requestReadReceipt         = $requestReadReceipt.IsPresent
    issuppressAutomaticReplies = $issuppressAutomaticReplies.IsPresent
  }
  if ($PSBoundParameters.ContainsKey("cc")){
    $mail.Add("cc", ($cc -join ",")) | Out-Null
  }
  if ($PSBoundParameters.ContainsKey("bcc")){
    $mail.Add("bcc", ($bcc -join ",")) | Out-Null
  } 
  if ($PSBoundParameters.ContainsKey("replyTo")){
    $mail.Add("replyTo", $replyTo) | Out-Null
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($mail | ConvertTo-Json) -Verbose:$VerbosePreference -Method "post" | Out-Null
  } 
  catch{
    throw $_
  } 
}
#EndRegion '.\Public\Send-TopdeskEmail.ps1' 47
#Region '.\Public\Set-TopdeskAssetAssignments.ps1' 0
<#
  .DESCRIPTION
  
  .PARAMETER assetids
  is an asset, stock or bulk item ID array. Multiple values of the array is supported
  .PARAMETER linkType
  is the type of the target card - branch, location for assets, stocks and bulk items while person, personGroup is only for assets
  .PARAMETER linkToId
  is the ID of the target card
  .PARAMETER branchId
  is the parent branch ID of the location.
#>
function Set-TopdeskAssetAssignments{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  [Alias("Add-TopdeskAssetAssignment")]
  param(
    [Alias("assetid")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string[]]$assetids,
    [Parameter()][ValidateSet("branch", "location", "personGroup","person")][string]$linkType = "branch",
    [Alias("locationID")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$linkToId,
    [Parameter()][ValidateNotNullOrEmpty()][string]$branchId
  )
  $vars = @{
    Method = "PUT"
    Verbose = $VerbosePreference
  }
  $body = @{
    linkType = $linkType
    linkToId = $linktoid    
  }
  if($PSBoundParameters.ContainsKey("branchId")){
    $body.branchId = $branchId
  }  
  if($assetids.count -gt 1){
    $vars.endpoint = "/tas/api/assetmgmt/assets/assignments"
    $body.assetIds = $assetids
  }
  else{
    $vars.endpoint = "/tas/api/assetmgmt/assets/$($assetids)/assignments"
  }
  $vars.body = $body | ConvertTo-Json
  try{
    $results = Get-TopdeskAPIResponse @vars
  }
  catch{
    throw $_
  }
  return $results.Results
}
#EndRegion '.\Public\Set-TopdeskAssetAssignments.ps1' 50
#Region '.\Public\Set-TopdeskHeader.ps1' 0
<#
  .DESCRIPTION
  This will set the header information for the topdesk API calls that will be used in the future. These are stored in a global variable so that they can be used both in other functions and scripts.
  .PARAMETER credential
  The credential object that will be used to authenticate with the Topdesk API.
  .PARAMETER username
  The username that will be used to authenticate with the Topdesk API.
  .PARAMETER password
  The password that will be used to authenticate with the Topdesk API. This is a secure string.
  .PARAMETER tenant
  The tenant that will be used to authenticate with the Topdesk API. It also has an alias for backwards compat for environment
  .EXAMPLE
  Create the header information with a credential object
    Set-TopdeskHeader -credential $credential -tenant "test-tenant"
  Create the header information with a username and password
    Set-TopdeskHeader -username "test-user" -password "test-password" -tenant "test-tenant"
#>
function Set-TopdeskHeader {
  [CmdletBinding()]
  [Alias("Connect-Topdesk")]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "credentialObject")][ValidateNotNullOrEmpty()][pscredential]$credential,
    [Parameter(Mandatory = $true, ParameterSetName = "usernamePassword")][ValidateNotNullOrEmpty()][string]$username,
    [Parameter(Mandatory = $true, ParameterSetName = "usernamePassword")][ValidateNotNullOrEmpty()][securestring]$password,
    [Alias("environment")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$tenant,
    [Parameter()][ValidateNotNullOrEmpty()][string]$contentType = "application/json"
  )
  # Deterime if we are are using the credential object or passed username and password
  if($PSCmdlet.ParameterSetName -eq "credentialObject"){
    $username = $credential.UserName
    $password = $credential.Password
  }
  $pass = ConvertFrom-SecureString -SecureString $password -AsPlainText
  # Create Topdesk header information that will be used with further API Calls
  $global:topdeskHeader = @{
    "Authorization" = "Basic $([System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($username):$($pass)")))"
    "Content-Type" = $contentType
  }
  # This sets a variable for the enviorment
  $global:topdeskAPIEndpoint = "https://$($tenant).topdesk.net"
}
#EndRegion '.\Public\Set-TopdeskHeader.ps1' 42
#Region '.\Public\Set-TopdeskIncident.ps1' 0
function Set-TopdeskIncident{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = 'id')][string]$id,
    [Parameter(Mandatory = $true, ParameterSetName = 'number')][string]$number,
    [Parameter()][ValidateNotNullOrEmpty()][PSCustomObject]$body,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_branch_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_dynamicName,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_phoneNumber,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_mobileNumber,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_email,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_department_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_department_name,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_location_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_budgetHolder_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_budgetHolder_name,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_personExtraFieldA_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_personExtraFieldA_name,   
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_personExtraFieldB_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_personExtraFieldB_name,     
    [Parameter()][ValidateNotNullOrEmpty()][string]$caller_callerLookup_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$status,
    [Parameter()][ValidateNotNullOrEmpty()][string]$briefDescription,
    [Parameter()][ValidateNotNullOrEmpty()][string]$request,
    [Parameter()][ValidateNotNullOrEmpty()][string]$action,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$actionInvisibleForCaller,
    [Parameter()][ValidateNotNullOrEmpty()][string]$entryType_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$entryType_name,    
    [Parameter()][ValidateNotNullOrEmpty()][string]$callType_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$callType_name, 
    [Parameter()][ValidateNotNullOrEmpty()][string]$category_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$category_name,    
    [Parameter()][ValidateNotNullOrEmpty()][string]$subcategory_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$subcategory_name, 
    [Parameter()][ValidateNotNullOrEmpty()][string]$externalNumber,       
    [Parameter()][ValidateNotNullOrEmpty()][string]$object_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$object_name, 
    [Parameter()][ValidateNotNullOrEmpty()][string]$location_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$branch_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$mainIncident_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$mainIncident_number, 
    [Parameter()][ValidateNotNullOrEmpty()][string]$impact_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$impact_name, 
    [Parameter()][ValidateNotNullOrEmpty()][string]$urgency_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$urgency_name, 
    [Parameter()][ValidateNotNullOrEmpty()][string]$priority_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$priority_name, 
    [Parameter()][ValidateNotNullOrEmpty()][string]$duration_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$duration_name,    
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$targetDate,
    [Parameter()][ValidateNotNullOrEmpty()][string]$sla_id,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$onHold,
    [Parameter()][ValidateNotNullOrEmpty()][string]$operator_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$operatorGroup_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$supplier_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$processingStatus_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$processingStatus_name,  
    [Parameter()][ValidateNotNullOrEmpty()][bool]$responded,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$responseDate,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$completed,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$completedDate,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$closed,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$closedDate,
    [Parameter()][ValidateNotNullOrEmpty()][string]$closureCode_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$closureCode_name, 
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$costs,
    [Parameter()][ValidateNotNullOrEmpty()][int]$feedbackRating,
    [Parameter()][ValidateNotNullOrEmpty()][string]$feedbackMessage, 
    [Parameter()][ValidateNotNullOrEmpty()][bool]$majorCall,
    [Parameter()][ValidateNotNullOrEmpty()][string]$majorCallObject_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$majorCallObject_number, 
    [Parameter()][ValidateNotNullOrEmpty()][bool]$publishToSsd,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$optionalFields1_boolean1,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$optionalFields1_boolean2,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$optionalFields1_boolean3,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$optionalFields1_boolean4,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$optionalFields1_boolean5,
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$optionalFields1_number1,
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$optionalFields1_number2,
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$optionalFields1_number3,
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$optionalFields1_number4,
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$optionalFields1_number5,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_text1,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_text2,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_text3,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_text4,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_text5,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_memo1,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_memo2,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_memo3,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_memo4,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_memo5,    
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$optionalFields1_date1,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$optionalFields1_date2,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$optionalFields1_date3,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$optionalFields1_date4,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$optionalFields1_date5,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_searchlist1_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_searchlist1_name,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_searchlist2_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_searchlist2_name,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_searchlist3_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_searchlist3_name,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_searchlist4_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_searchlist4_name,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_searchlist5_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields1_searchlist5_name,                
    [Parameter()][ValidateNotNullOrEmpty()][bool]$optionalFields2_boolean1,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$optionalFields2_boolean2,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$optionalFields2_boolean3,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$optionalFields2_boolean4,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$optionalFields2_boolean5,
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$optionalFields2_number1,
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$optionalFields2_number2,
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$optionalFields2_number3,
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$optionalFields2_number4,
    [Parameter()][ValidateNotNullOrEmpty()][decimal]$optionalFields2_number5,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_text1,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_text2,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_text3,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_text4,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_text5,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_memo1,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_memo2,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_memo3,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_memo4,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_memo5,    
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$optionalFields2_date1,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$optionalFields2_date2,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$optionalFields2_date3,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$optionalFields2_date4,
    [Parameter()][ValidateNotNullOrEmpty()][datetime]$optionalFields2_date5,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_searchlist1_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_searchlist1_name,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_searchlist2_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_searchlist2_name,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_searchlist3_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_searchlist3_name,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_searchlist4_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_searchlist4_name,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_searchlist5_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$optionalFields2_searchlist5_name,      
    [Parameter()][ValidateNotNullOrEmpty()][string]$externalLink_id,
    [Parameter()][ValidateNotNullOrEmpty()][string]$externalLink_type,
    [Parameter()][ValidateNotNullOrEmpty()][string]$externalLink_date
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)"
  }
  elseif ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)"
  }
  if (-not $PSBoundParameters.ContainsKey("body")) {
    $body = @{}
    foreach($item in $PsBoundParameters.GetEnumerator()){
      if($item.key -in ("Verbose","id","number")){continue}
      $key = $item.Key.split("_")
      if($key.count -gt 1){
        $parent = ""
        for($i = 0; $i -lt $key.count - 1; $i++){
          if($i -eq 0){
            if(!$body.ContainsKey($key[$i])){
              $body.Add($key[$i],@{}) | Out-Null
            }
            $parent = $key[$i]
          }
          else{
            $scriptBlock = "
              if(!`$body.$($parent).ContainsKey(`"$($key[$i])`")){
                `$body.$($parent).Add(`"$($key[$i])`",@{}) | Out-Null
              }
              `$parent = `"$($parent).$($key[$i])`"
            "
            Invoke-Expression $scriptBlock
          }
        }
        $scriptBlock = "
          `$body.$($parent).Add(`"$($key[$i])`",`$item.value)
        "
        Invoke-Expression $scriptBlock
      }
      else{
        if(!$body.ContainsKey($item.Key)){
          $body.Add($item.Key,$item.Value) | Out-Null
        }
      }
    }
  }
  try {
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Method "PUT" -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference -AllowInsecureRedirect
    Write-Verbose "Updating incident." 
  } 
  catch {
    throw $_
  } 
  return $results.results
}
#EndRegion '.\Public\Set-TopdeskIncident.ps1' 199
#Region '.\Public\Set-TopdeskIncidentArchive.ps1' 0
function Set-TopdeskIncidentArchive{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "id")][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true, ParameterSetName = "number")][ValidateNotNullOrEmpty()][string]$number,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$reason
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/archive"
  }
  if ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/archive"
  } 
  $body = @{
    "name" = $reason
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference -Method "Put" | Out-Null
    Write-Verbose "Archived incident id $($number)." 
  } 
  catch{
    throw $_
  }   
}
#EndRegion '.\Public\Set-TopdeskIncidentArchive.ps1' 26
#Region '.\Public\Set-TopdeskIncidentDeescalation.ps1' 0
function Set-TopdeskIncidentDeescalation{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "id")][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true, ParameterSetName = "number")][ValidateNotNullOrEmpty()][string]$number,
    [Parameter()][ValidateNotNullOrEmpty()][string]$reason,
    [Parameter()][ValidateNotNullOrEmpty()][string]$reasonid    
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/deescalate"
  }
  if ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/deescalate"
  }  
  if ($PSBoundParameters.ContainsKey("reason")) {
    $body = @{"name" = $reason}
  }
  if ($PSBoundParameters.ContainsKey("reasonid")) {
    $body = @{"id" = $reasonid}
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference -Method "Put" | Out-Null
    Write-Verbose "Deescanted incident id $($number)." 
  } 
  catch{
    throw $_
  }
}
#EndRegion '.\Public\Set-TopdeskIncidentDeescalation.ps1' 30
#Region '.\Public\Set-TopdeskIncidentEscalation.ps1' 0
function Set-TopdeskIncidentEscalation{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "id")][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true, ParameterSetName = "number")][ValidateNotNullOrEmpty()][string]$number,
    [Parameter()][ValidateNotNullOrEmpty()][string]$reason,
    [Parameter()][ValidateNotNullOrEmpty()][string]$reasonid
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/escalate"
  }
  if ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/escalate"
  } 
  if ($PSBoundParameters.ContainsKey("reason")) {
    $body = @{"name" = $reason}
  }
  if ($PSBoundParameters.ContainsKey("reasonid")) {
    $body = @{"id" = $reasonid}
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference -Method "Put" | Out-Null
    Write-Verbose "Escanted incident id $($number)." 
  } 
  catch{
    throw $_
  }   
}
#EndRegion '.\Public\Set-TopdeskIncidentEscalation.ps1' 30
#Region '.\Public\Set-TopdeskIncidentUnarchive.ps1' 0
function Set-TopdeskIncidentUnarchive{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true, ParameterSetName = "id")][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true, ParameterSetName = "number")][ValidateNotNullOrEmpty()][string]$number
  )
  if ($PSBoundParameters.ContainsKey("id")) {
    $endpoint = "/tas/api/incidents/id/$($id)/unarchive"
  }
  if ($PSBoundParameters.ContainsKey("number")) {
    $endpoint = "/tas/api/incidents/number/$($number)/unarchive"
  } 
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference -Method "Put" | Out-Null
    Write-Verbose "Unarchived incident id $($number)." 
  } 
  catch{
    throw $_
  }   
}
#EndRegion '.\Public\Set-TopdeskIncidentUnarchive.ps1' 22
#Region '.\Public\Set-TopdeskKnowledgeItemArchive.ps1' 0
function Set-TopdeskKnowledgeItemArchive{
  [CmdletBinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/archive"
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference -Method "POST" | Out-Null
    Write-Verbose "Archived KI id $($id)." 
  } 
  catch{
    throw $_
  }    
}
#EndRegion '.\Public\Set-TopdeskKnowledgeItemArchive.ps1' 16
#Region '.\Public\Set-TopdeskKnowledgeItemStatusArchive.ps1' 0
function Set-TopdeskKnowledgeItemStatusArchive{
  [cmdletbinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItemStatuses/$($id)/archive"
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference -Method "POST" | Out-Null
  } 
  catch{
    throw $_
  } 
}
#EndRegion '.\Public\Set-TopdeskKnowledgeItemStatusArchive.ps1' 15
#Region '.\Public\Set-TopdeskKnowledgeItemStatusUnarchive.ps1' 0
function Set-TopdeskKnowledgeItemStatusUnarchive{
  [cmdletbinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItemStatuses/$($id)/unarchive"
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -Verbose:$VerbosePreference -Method "POST" | Out-Null
  } 
  catch{
    throw $_
  } 
}
#EndRegion '.\Public\Set-TopdeskKnowledgeItemStatusUnarchive.ps1' 15
#Region '.\Public\Set-TopdeskKnowledgeItemUnarchive.ps1' 0
function Set-TopdeskKnowledgeItemUnarchive{
  [CmdletBinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/unarchive"
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference -Method "POST" | Out-Null
    Write-Verbose "Unarchived KI id $($id)." 
  } 
  catch{
    throw $_
  }    
}
#EndRegion '.\Public\Set-TopdeskKnowledgeItemUnarchive.ps1' 16
#Region '.\Public\Set-TopdeskPersonArchive.ps1' 0
function Set-TopdeskPersonArchive{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter(Mandatory = $true)][string]$id,
    [Parameter()][string]$reason_id
  )
  $endpoint = "/tas/api/persons/id/$($id)/archive"
  $body = @{}
  if ($PSBoundParameters.ContainsKey("reason_id")) { 
    $body.Add("id",$reason_id)
  } 
  try {
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Method PUT -body ($body | ConvertTo-Json) -Verbose:$VerbosePreference
  }
  catch {
    throw $_
  }  
  return $results.results  
}
#EndRegion '.\Public\Set-TopdeskPersonArchive.ps1' 21
#Region '.\Public\Set-TopdeskPersons.ps1' 0
function Set-TopdeskPersons{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true)][string]$id,
    [Parameter()][String]$Surname,
    [Parameter()][String]$firstName,
    [Parameter()][String]$firstInitials,
    [Parameter()][String]$prefixes,
    [Parameter()][String]$birthName,
    [Parameter()][ValidateSet("UNDEFINED", "MALE", "FEMALE")][String]$gender,
    [Parameter()][String]$employeeNumber,
    [Parameter()][String]$networkLoginName,
    [Parameter()][String]$mainframeLoginName,
    [Parameter()][String]$branch_id,
    [Parameter()][String]$location_id,
    [Parameter()][String]$department_id,
    [Parameter()][String]$language_id,
    [Parameter()][String]$departmentFree,
    [Parameter()][String]$tasLoginName,
    [Parameter()][SecureString]$password,
    [Parameter()][String]$phoneNumber,
    [Parameter()][String]$mobileNumber,
    [Parameter()][String]$fax,
    [Parameter()][String]$email,
    [Parameter()][String]$title,
    [Parameter()][String]$jobTitle,
    [Parameter()][bool]$showBudgetholder,
    [Parameter()][bool]$showDepartment,
    [Parameter()][bool]$showBranch,
    [Parameter()][bool]$showSubsidiaries,
    [Parameter()][bool]$showAllBranches,
    [Parameter()][bool]$authorizeAll,
    [Parameter()][bool]$authorizeDepartment,
    [Parameter()][bool]$authorizeBudgetHolder,
    [Parameter()][bool]$authorizeBranch,
    [Parameter()][bool]$authorizeSubsidiaryBranches,
    [Parameter()][bool]$optionalFields1_boolean1,
    [Parameter()][bool]$optionalFields1_boolean2,
    [Parameter()][bool]$optionalFields1_boolean3,
    [Parameter()][bool]$optionalFields1_boolean4,
    [Parameter()][bool]$optionalFields1_boolean5,
    [Parameter()][double]$optionalFields1_number1,
    [Parameter()][double]$optionalFields1_number2,
    [Parameter()][double]$optionalFields1_number3,
    [Parameter()][double]$optionalFields1_number4,
    [Parameter()][double]$optionalFields1_number5,
    [Parameter()][datetime]$optionalFields1_date1,
    [Parameter()][datetime]$optionalFields1_date2,
    [Parameter()][datetime]$optionalFields1_date3,
    [Parameter()][datetime]$optionalFields1_date4,
    [Parameter()][datetime]$optionalFields1_date5,
    [Parameter()][string]$optionalFields1_text1,
    [Parameter()][string]$optionalFields1_text2,
    [Parameter()][string]$optionalFields1_text3,
    [Parameter()][string]$optionalFields1_text4,
    [Parameter()][string]$optionalFields1_text5,
    [Parameter()][string]$optionalFields1_searchlist1_id,
    [Parameter()][string]$optionalFields1_searchlist2_id,
    [Parameter()][string]$optionalFields1_searchlist3_id,
    [Parameter()][string]$optionalFields1_searchlist4_id,
    [Parameter()][string]$optionalFields1_searchlist5_id,
    [Parameter()][bool]$optionalFields2_boolean1,
    [Parameter()][bool]$optionalFields2_boolean2,
    [Parameter()][bool]$optionalFields2_boolean3,
    [Parameter()][bool]$optionalFields2_boolean4,
    [Parameter()][bool]$optionalFields2_boolean5,
    [Parameter()][double]$optionalFields2_number1,
    [Parameter()][double]$optionalFields2_number2,
    [Parameter()][double]$optionalFields2_number3,
    [Parameter()][double]$optionalFields2_number4,
    [Parameter()][double]$optionalFields2_number5,
    [Parameter()][datetime]$optionalFields2_date1,
    [Parameter()][datetime]$optionalFields2_date2,
    [Parameter()][datetime]$optionalFields2_date3,
    [Parameter()][datetime]$optionalFields2_date4,
    [Parameter()][datetime]$optionalFields2_date5,
    [Parameter()][string]$optionalFields2_text1,
    [Parameter()][string]$optionalFields2_text2,
    [Parameter()][string]$optionalFields2_text3,
    [Parameter()][string]$optionalFields2_text4,
    [Parameter()][string]$optionalFields2_text5,
    [Parameter()][string]$optionalFields2_searchlist1_id,
    [Parameter()][string]$optionalFields2_searchlist2_id,
    [Parameter()][string]$optionalFields2_searchlist3_id,
    [Parameter()][string]$optionalFields2_searchlist4_id,
    [Parameter()][string]$optionalFields2_searchlist5_id,
    [Parameter()][string]$budgetHolder_id,
    [Parameter()][string]$personExtraFieldA_id,
    [Parameter()][string]$personExtraFieldB_id,
    [Parameter()][string]$attention_id,
    [Parameter()][string]$attentionComment,
    [Parameter()][bool]$isManager,
    [Parameter()][string]$manager_id 
  ) 
  # The endpoint to get assets
  $endpoint = "/tas/api/persons/id/$($id)"
  $body = @{}
  foreach($p in $PSBoundParameters.GetEnumerator()){
    if($p.key -in ("id","Verbose","Debug","ErrorAction","WarningAction","InformationAction","ErrorVariable","WarningVariable","InformationVariable","OutVariable","OutBuffer")){continue}
    if($p.key -match "_"){
      $split = $p.key -split "_"
      $nested = @{}
      for($i = ($split.length -1); $i -gt 0; $i--){
        if($i -eq ($split.length -1)){
          $nested = @{$split[$i] = $p.value}
        }
        else{
          $nested = @{$split[$i] = $nested}
        }
      }
      $body.Add($split[0],$nested)
    }
    elseif($p.key -match "password"){
      $body.add($p.key,(ConvertFrom-SecureString -SecureString $p.value -AsPlainText))
    }
    else{
      $body.add($p.key,$p.value)
    }    
  }
  try {
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Method "PATCH" -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference -AllowInsecureRedirect
    Write-Verbose "Updating incident." 
  } 
  catch {
    throw $_
  } 
  return $results.results
}
#EndRegion '.\Public\Set-TopdeskPersons.ps1' 130
#Region '.\Public\Set-TopdeskPersonsContract.ps1' 0
function Set-TopdeskPersonsContract {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true)][string]$id,
    [Parameter()][datetime]$hireDate,
    [Parameter()][datetime]$employmentTerminationDate,
    [Parameter()][datetime]$contractStartDate,
    [Parameter()][datetime]$contractExpiryDate,
    [Parameter()][datetime]$endProbationPeriod
  )  
  $endpoint = "/tas/api/persons/id/$($id)/contract"
  $body = @{}  
  if ($PSBoundParameters.ContainsKey("hireDate")) { $body.Add("hireDate", $hireDate) }
  if ($PSBoundParameters.ContainsKey("employmentTerminationDate")) { $body.Add("employmentTerminationDate", $employmentTerminationDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")) }
  if ($PSBoundParameters.ContainsKey("contractStartDate")) { $body.Add("contractStartDate", $contractStartDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")) }
  if ($PSBoundParameters.ContainsKey("contractExpiryDate")) { $body.Add("contractExpiryDate", $contractExpiryDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")) }
  if ($PSBoundParameters.ContainsKey("endProbationPeriod")) { $body.Add("endProbationPeriod", $endProbationPeriod.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")) }
  try {
    if($body.count -gt 0){
      $results = Get-TopdeskAPIResponse -endpoint $endpoint -Method PATCH -body ($body | ConvertTo-Json) -Verbose:$VerbosePreference
    }
  }
  catch {
    throw $_
  }  
  return $results.results   
}
#EndRegion '.\Public\Set-TopdeskPersonsContract.ps1' 29
#Region '.\Public\Set-TopdeskPersonsPrivateDetails.ps1' 0
function Set-TopdeskPersonsPrivateDetails{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true)][string]$id,
    [Parameter()][string]$privatePhoneNumber1,
    [Parameter()][string]$privatePhoneNumber2,
    [Parameter()][string]$privateMobilePhoneNumber,
    [Parameter()][string]$privateFaxNumber,
    [Parameter()][string]$socialSecurityNumber,
    [Parameter()][string]$privateEmail,
    [Parameter()][string]$country,
    [Parameter()][string]$street,
    [Parameter()][string]$number,
    [Parameter()][string]$county,
    [Parameter()][string]$city,
    [Parameter()][string]$postcode,
    [Parameter()][string]$addressMemo
  )
  $endpoint = "/tas/api/persons/id/$($id)/privateDetails"
  $body = @{}
  $address = @{}
  if ($PSBoundParameters.ContainsKey("privatePhoneNumber1")) { $body.Add("privatePhoneNumber1",$privatePhoneNumber1)}   
  if ($PSBoundParameters.ContainsKey("privatePhoneNumber2")) { $body.Add("privatePhoneNumber2",$privatePhoneNumber2)}   
  if ($PSBoundParameters.ContainsKey("privateMobilePhoneNumber")) { $body.Add("privateMobilePhoneNumber",$privateMobilePhoneNumber)}   
  if ($PSBoundParameters.ContainsKey("privateFaxNumber")) { $body.Add("privateFaxNumber",$privateFaxNumber)}   
  if ($PSBoundParameters.ContainsKey("socialSecurityNumber")) { $body.Add("socialSecurityNumber",$privateFaxNumber)}   
  if ($PSBoundParameters.ContainsKey("privateEmail")) { $body.Add("privateEmail",$privateFaxNumber)}   
  if ($PSBoundParameters.ContainsKey("country")) { $address.Add("country",$country)}   
  if ($PSBoundParameters.ContainsKey("street")) { $address.Add("street",$street)}   
  if ($PSBoundParameters.ContainsKey("number")) { $address.Add("number",$number)}   
  if ($PSBoundParameters.ContainsKey("city")) { $address.Add("city",$city)}   
  if ($PSBoundParameters.ContainsKey("postcode")) { $address.Add("postcode",$postcode)}   
  if ($PSBoundParameters.ContainsKey("addressMemo")) { $address.Add("addressMemo",$addressMemo)}
  if($address.count -gt 0){
    $body.Add("address",$address)
  }
  try {
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Method PATCH -body ($body | ConvertTo-Json) -Verbose:$VerbosePreference
  }
  catch {
    throw $_
  }  
  return $results.results 
}
#EndRegion '.\Public\Set-TopdeskPersonsPrivateDetails.ps1' 46
#Region '.\Public\Set-TopdeskPersonUnArchive.ps1' 0
function Set-TopdeskPersonUnArchive {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSObject]])]
  param(
    [Parameter(Mandatory = $true)][string]$id
  )
  $endpoint = "/tas/api/persons/id/$($id)/unarchive"
  try {
    $results = Get-TopdeskAPIResponse -endpoint $endpoint -Method PUT -Verbose:$VerbosePreference
  }
  catch {
    throw $_
  }  
  return $results.results  
}
#EndRegion '.\Public\Set-TopdeskPersonUnArchive.ps1' 16
#Region '.\Public\Update-TopdeskAsset.ps1' 0
function Update-TopdeskAsset{
  [CmdletBinding()]
  param(
    [Alias("unid")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$assetId,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][hashtable]$update
  )
  # The endpoint to get assets
  $endpoint = "/tas/api/assetmgmt/assets/$($assetId)"  
  try{
    Get-TopdeskAPIResponse -endpoint $endpoint -Method "POST" -body ($update | ConvertTo-JSON) -Verbose:$VerbosePreference | Out-Null
    Write-Verbose "Updating asset with id $($assetId) from system." 
  } 
  catch{
    throw $_
  }  
}
#EndRegion '.\Public\Update-TopdeskAsset.ps1' 17
#Region '.\Public\Update-TopdeskKnowledgeItem.ps1' 0
function Update-TopdeskKnowledgeItem {
  [cmdletbinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter()]$body,
    [Parameter()][string]$parent,
    [Parameter()][ValidateSet("NOT_VISIBLE", "VISIBLE", "VISIBLE_IN_PERIOD")][string]$sspVisibility = "NOT_VISIBLE",
    [Parameter()][datetime]$sspVisibleFrom,
    [Parameter()][datetime]$sspVisibleUntil,
    [Parameter()][bool]$sspVisibilityFilteredOnBranches = $false,
    [Parameter()][bool]$operatorVisibilityFilteredOnBranches = $false,
    [Parameter()][bool]$openKnowledgeItem,
    [Parameter()][string]$status,
    [Parameter()][string]$manager,
    [Parameter()][string]$externalLinkid,
    [Parameter()][string]$externalLinktype,
    [Parameter()][datetime]$externalLinkdate
  )
  # The endpoint to get assets
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)"
  if (-not $PSBoundParameters.ContainsKey("body")) {
    # Create blank body
    $body = @{}
    # Add the parent if it exists
    if ($PSBoundParameters.ContainsKey("parent")) {
      $body.Add("parent", @{number = $parent })
    }
    # Create blank visibility hash to add if required
    $visibility = @{
      operatorVisibilityFilteredOnBranches = $operatorVisibilityFilteredOnBranches
      sspVisibilityFilteredOnBranches      = $sspVisibilityFilteredOnBranches    
      sspVisibility                        = $sspVisibility  
    }
    if ($PSBoundParameters.ContainsKey("sspVisibleFrom")) {
      $visibility.Add("sspVisibleFrom", $sspVisibleFrom.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))
    }
    if ($PSBoundParameters.ContainsKey("sspVisibleUntil")) {
      $visibility.Add("sspVisibleUntil", $sspVisibleUntil.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))
    }  
    if ($PSBoundParameters.ContainsKey("openKnowledgeItem")) {
      $visibility.Add("openKnowledgeItem", $openKnowledgeItem)
    }
    if ($visibility.count -ne 0) {
      $body.Add("visibility", $visibility)
    }
    if ($PSBoundParameters.ContainsKey("status")) {
      $body.Add("status", @{id = $status })
    }
    if ($PSBoundParameters.ContainsKey("manager")) {
      $body.Add("manager", @{id = $manager })
    }  
    # Create blank externalLink hash to add if required
    $externalLink = @{}
    if ($PSBoundParameters.ContainsKey("externalLinkid")) {
      $externalLink.Add("id", $externalLinkid)
    }
    if ($PSBoundParameters.ContainsKey("externalLinktype")) {
      $externalLink.Add("type", $externalLinktype)
    }   
    if ($PSBoundParameters.ContainsKey("externalLinkdate")) {
      $externalLink.Add("date", $externalLinkdate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))
    }    
    if ($externalLink.count -ne 0) {
      $body.Add("externalLink", $externalLink)
    }  
  }
  try {
    Get-TopdeskAPIResponse -endpoint $endpoint -Method "POST" -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference | Out-Null
    Write-Verbose "Updating knowledgeitem with id $($id) from system." 
  } 
  catch {
    throw $_
  }   
}
#EndRegion '.\Public\Update-TopdeskKnowledgeItem.ps1' 75
#Region '.\Public\Update-TopdeskKnowledgeItemStatues.ps1' 0
function Update-TopdeskKnowledgeItemStatues{
  [cmdletbinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$name
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItemStatuses/$($id)"
  $body = @{
    name = $name
  }
  try{
    # Execute API Call
    Get-TopdeskAPIResponse -endpoint $endpoint -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference -Method "PATCH" | Out-Null
  } 
  catch{
    throw $_
  }     
}
#EndRegion '.\Public\Update-TopdeskKnowledgeItemStatues.ps1' 19
#Region '.\Public\Update-TopdeskKnowledgeItemTranslation.ps1' 0
function Update-TopdeskKnowledgeItemTranslation{
  [cmdletbinding()]
  param(
    [Alias("identifier")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter()][string]$language = "en-CA",
    [Parameter(Mandatory = $true, ParameterSetName = 'body')][PSCustomObject]$body,
    [Parameter(ParameterSetName = 'Title')][string]$title,
    [Parameter(ParameterSetName = 'Title')][string]$description,
    [Parameter(ParameterSetName = 'Title')][string]$content,
    [Parameter(ParameterSetName = 'Title')][string]$commentsForOperators,
    [Parameter(ParameterSetName = 'Title')][string]$keywords
  )
  $endpoint = "/services/knowledge-base-v1/knowledgeItems/$($id)/translations/$($language)"
  if (-not $PSBoundParameters.ContainsKey("body")){
    $body = @{}
    if ($PSBoundParameters.ContainsKey("title")){$body.Add("title",$title) | Out-Null}
    if ($PSBoundParameters.ContainsKey("description")){$body.Add("description",$description) | Out-Null}
    if ($PSBoundParameters.ContainsKey("content")){$body.Add("content",$content) | Out-Null}
    if ($PSBoundParameters.ContainsKey("commentsForOperators")){$body.Add("commentsForOperators",$commentsForOperators) | Out-Null}
    if ($PSBoundParameters.ContainsKey("keywords")){$body.Add("keywords",$keywords) | Out-Null}
  }
  try{
    Get-TopdeskAPIResponse -endpoint $endpoint -Method "POST" -body ($body | ConvertTo-JSON) -Verbose:$VerbosePreference | Out-Null
    Write-Verbose "Updating knowledgeitem with id $($id) from system." 
  } 
  catch{
    throw $_
  }   
}
#EndRegion '.\Public\Update-TopdeskKnowledgeItemTranslation.ps1' 30
