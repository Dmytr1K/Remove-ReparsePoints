#requires -Version 5.1
#requires -Modules PowerShellGet

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$DependenciesPath = Join-Path $PSScriptRoot 'DevelopmentDependencies.psd1'
$DevelopmentDependencies = Import-PowerShellDataFile -LiteralPath $DependenciesPath

foreach ($Dependency in $DevelopmentDependencies.Dependencies) {
  $RequiredVersion = [version] $Dependency.RequiredVersion
  $InstalledModule = Get-Module -ListAvailable -Name $Dependency.Name |
    Where-Object { $_.Version -eq $RequiredVersion } |
    Select-Object -First 1

  if ($InstalledModule) {
    Write-Information `
      -MessageData "$($Dependency.Name) $RequiredVersion is already installed." `
      -InformationAction Continue
    continue
  }

  Write-Information `
    -MessageData "Installing $($Dependency.Name) $RequiredVersion for the current user..." `
    -InformationAction Continue

  Install-Module `
    -Name $Dependency.Name `
    -RequiredVersion $RequiredVersion `
    -Repository 'PSGallery' `
    -Scope CurrentUser `
    -Force `
    -SkipPublisherCheck

  $InstalledModule = Get-Module -ListAvailable -Name $Dependency.Name |
    Where-Object { $_.Version -eq $RequiredVersion } |
    Select-Object -First 1

  if (-not $InstalledModule) {
    throw "Failed to install $($Dependency.Name) $RequiredVersion."
  }
}

Write-Information `
  -MessageData 'Development dependencies are ready.' `
  -InformationAction Continue
