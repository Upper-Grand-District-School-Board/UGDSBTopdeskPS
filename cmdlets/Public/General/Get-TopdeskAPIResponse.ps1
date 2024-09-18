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