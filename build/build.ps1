#
#   Copyright (c) 2015 ParseStack Software Ltd.
#
$buildRoot = $PSSCriptRoot
$pkgName = "posh-hello"


#
#   Get-FeedRepositoy:
#
#       return the feed repository object parsed from feed.repository.json
#
Function Get-FeedRepository
{
    if (! (Test-Path "$buildRoot\feed.repository.json"))
    {
        Write-Warning ".\build\feed.repository.json file is required."
        Write-Warning "Please create and populate this file and then try again"
        return
    }

    return Get-Content "$buildRoot\feed.repository.json" | Out-String | ConvertFrom-Json
}


#
#   New-Package:
#
#       parse the version information and increment the revision #
#       generate a temporary nuspec file with the version information update
#       generate the NuGet package from the tempory nuspec file
#       clean-up
#
Function New-Package
{
    $pkgRoot = "$buildRoot\..\src"
    $tempNuspec = "$pkgRoot\temp.$pkgName.nuspec"

    $version = Get-Content "$buildRoot\version.json" | Out-String | ConvertFrom-Json
    $version.revision++
    $major = $version.majorVersion
    $minor = $version.minorVersion
    $revision = $version.revision
    $versionString = "$major.$minor.$revision"

    $nuspec = Get-Content "$pkgRoot\$pkgName.nuspec" | Out-String
    $nuspec -Replace "__MAJORVERSION__.__MINORVERSION__.__REVISION__", "$versionString" | Set-Content $tempNuspec

    Write-Host "Creating package $pkgName.$versionString.nuget"
    nuget pack $tempNuspec 2>&1 > $null

    #
    #   remove the temporary file
    #   update the version file
    #
    Remove-Item $tempNuspec
    $version | ConvertTo-Json | Set-Content "$buildRoot\version.json"
    return (Get-ChildItem "$pkgName.$versionString.nupkg")
}


#
#   Publish-Package:
#
#       publish the specified package name to your NuGet feed
#
Function Publish-Package
{
Param(
    [Parameter(Position=0, Mandatory=$true)]
    [string] $pkgName
)

    $feedRepository = Get-FeedRepository
    nuget push $pkgName $feedRepository.apiKey -source $feedRepository.feedUrl
}
