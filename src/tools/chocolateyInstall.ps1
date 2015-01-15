#
#   Copyright (c) 2015 ParseStack Software Ltd.
#
#   Chocolatey powershell module installer
#
$packageName = "posh-hello"
$defaultModulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules"

try
{
    #
    #   allow users to control the install location for the powershell modules on the device
    #
    $installRoot = $env:chocolateyPowershellModuleInstallRoot;
    if ($installRoot -eq $null) { $installRoot = $defaultModulePath; }

    $root = $(Split-Path -parent (Split-Path -parent $MyInvocation.MyCommand.Definition))
    $contentRoot = $(Join-Path $root "content")

    Write-Host "Installed chocolatey package $packageName to $root"
    Write-Host "Installing $packageName PowerShell Module contents to $installRoot"

    if (! (Test-Path "$installRoot\$packageName"))
    {
        mkdir "$installRoot\$packageName"
    }

    Copy-Item -Path "$contentRoot\*.*" -Destination "$installRoot\$packageName" -Recurse

    $escapedInstallRoot = $installRoot.Replace("\", "\\");

    #
    #   preserve the install state of the package (in this case the install root for the module)
    #
    "{
        `"installRoot`" : `"$escapedInstallRoot`"
     }" | Set-Content "$root\installState.json"

    Write-ChocolateySuccess $packageName
}
catch
{
    Write-ChocolateyFailure $packageName $($_.Exception.Message)
    throw
}
