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