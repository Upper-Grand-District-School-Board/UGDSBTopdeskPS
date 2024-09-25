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