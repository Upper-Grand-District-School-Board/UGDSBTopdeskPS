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