#
#   Copyright (c) 2015 ParseStack Software Ltd.
#
#   Chocolatey powershell module uninstaller
#

$packageName = "posh-hello"

try
{
    #
    #   allow users to control the install location for the powershell modules on the device
    #
    $root = $(Split-Path -parent (Split-Path -parent $MyInvocation.MyCommand.Definition))
    $installState = (Get-Content "$root\installState.json" | Out-String | ConvertFrom-Json)
    $installRoot = $installState.installRoot

    if (Test-Path "$installRoot\$packageName")
    {
        Remove-Item "$installRoot\$packageName" -Recurse -Force
    }

    Write-ChocolateySuccess $packageName
}
catch
{
    Write-ChocolateyFailure $packageName $($_.Exception.Message)
    throw
}
