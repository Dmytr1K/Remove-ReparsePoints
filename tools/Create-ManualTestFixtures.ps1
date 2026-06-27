#requires -Version 5.1

# Create-ManualTestFixtures.ps1
#
# Manual test fixture generator for Remove-ReparsePoints.
#
# Goal:
# Create a safe test directory structure with regular files,
# directories, junctions, symbolic links, and hardlinks for manual testing.
#
# Notes:
# - This script is for local/manual testing only.
# - Use a dedicated empty test directory.
# - Do not target important real data.
# - Do not use dangerous locations such as a drive root, Windows directory,
#   active user profile, or project repository root.
# - The fixture root should be explicit and easy to delete.

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $Path
)

$ErrorActionPreference = 'Stop'

$RootPath = [System.IO.Path]::GetFullPath($Path)

# Declarative description of the file system structure to create.
$FileSystemLayout = [ordered]@{
  Entries = @(
    [ordered]@{
      Type         = 'Directory'
      RelativePath = '.'
    }
    [ordered]@{
      Type         = 'Directory'
      RelativePath = 'RegularDirectory'
      Attributes   = @('ReadOnly')
    }
    [ordered]@{
      Type         = 'File'
      RelativePath = 'RegularDirectory\RegularFile.txt'
      Content      = 'Regular file used by manual Remove-ReparsePoints tests.'
      Attributes   = @('ReadOnly')
    }
    [ordered]@{
      Type               = 'Junction'
      RelativePath       = 'JunctionToRegularDirectory'
      TargetRelativePath = 'RegularDirectory'
    }
    [ordered]@{
      Type               = 'DirectorySymlink'
      RelativePath       = 'DirectorySymlinkToRegularDirectory'
      TargetRelativePath = 'RegularDirectory'
    }
    [ordered]@{
      Type               = 'FileSymlink'
      RelativePath       = 'FileSymlinkToRegularFile.txt'
      TargetRelativePath = 'RegularDirectory\RegularFile.txt'
    }
    [ordered]@{
      Type               = 'Hardlink'
      RelativePath       = 'HardlinkToRegularFile.txt'
      TargetRelativePath = 'RegularDirectory\RegularFile.txt'
    }
  )
}

$AllowedEntryTypes = @(
  'Directory'
  'File'
  'Junction'
  'DirectorySymlink'
  'FileSymlink'
  'Hardlink'
)

$LinkEntryTypes = @(
  'Junction'
  'DirectorySymlink'
  'FileSymlink'
  'Hardlink'
)

foreach ($Entry in $FileSystemLayout.Entries) {
  if ([string]::IsNullOrWhiteSpace($Entry.Type)) {
    throw 'File system entry is missing required field: Type'
  }

  if ([string]::IsNullOrWhiteSpace($Entry.RelativePath)) {
    throw "File system entry '$($Entry.Type)' is missing required field: RelativePath"
  }

  if ($Entry.Type -notin $AllowedEntryTypes) {
    throw "Unsupported file system entry type: $($Entry.Type)"
  }

  if (($Entry.Type -in $LinkEntryTypes) -and [string]::IsNullOrWhiteSpace($Entry.TargetRelativePath)) {
    throw "File system entry '$($Entry.Type)' is missing required field: TargetRelativePath"
  }
}

# TODO: Add safety checks for dangerous root paths.
# Examples: drive root, Windows directory, active user profile, or repository root.

if (Test-Path -LiteralPath $RootPath) {
  throw "Fixture root already exists: $RootPath. Choose a new path or remove the existing directory manually."
}

New-Item -ItemType Directory -Path $RootPath | Out-Null

# TODO: Add optional recreate behavior for an existing fixture root.
# Current behavior: stop if the fixture root already exists.
# Later, decide whether to support:
# - allowing an empty existing directory
# - removing and recreating the fixture root
# - requiring an explicit -Force switch

function Invoke-Mklink {
  param(
    [Parameter(Mandatory = $true)]
    [string] $Command
  )

  $PreviousErrorActionPreference = $ErrorActionPreference

  try {
    $ErrorActionPreference = 'Continue'
    $Output = & cmd.exe /d /c $Command 2>&1
  }
  finally {
    $ErrorActionPreference = $PreviousErrorActionPreference
  }

  if ($LASTEXITCODE -ne 0) {
    throw "mklink failed: $Command`n$Output"
  }
}

foreach ($Entry in $FileSystemLayout.Entries) {
  $EntryPath = Join-Path -Path $RootPath -ChildPath $Entry.RelativePath

  switch ($Entry.Type) {
    'Directory' {
      New-Item -ItemType Directory -Path $EntryPath -Force | Out-Null
    }

    'File' {
      Set-Content -Path $EntryPath -Value $Entry.Content
    }

    'Junction' {
      $TargetPath = Join-Path -Path $RootPath -ChildPath $Entry.TargetRelativePath
      Invoke-Mklink -Command "mklink /J `"$EntryPath`" `"$TargetPath`""
    }

    'DirectorySymlink' {
      $TargetPath = Join-Path -Path $RootPath -ChildPath $Entry.TargetRelativePath
      Invoke-Mklink -Command "mklink /D `"$EntryPath`" `"$TargetPath`""
    }

    'FileSymlink' {
      $TargetPath = Join-Path -Path $RootPath -ChildPath $Entry.TargetRelativePath
      Invoke-Mklink -Command "mklink `"$EntryPath`" `"$TargetPath`""
    }

    'Hardlink' {
      $TargetPath = Join-Path -Path $RootPath -ChildPath $Entry.TargetRelativePath
      Invoke-Mklink -Command "mklink /H `"$EntryPath`" `"$TargetPath`""
    }
  }

  if ($Entry.Attributes) {
    $Item = Get-Item -LiteralPath $EntryPath -Force

    foreach ($Attribute in $Entry.Attributes) {
      $FileAttribute = [System.IO.FileAttributes] $Attribute
      $Item.Attributes = $Item.Attributes -bor $FileAttribute
    }
  }
}

Write-Host "Created manual test fixture: $RootPath"

# TODO: Add cleanup/reset behavior later if needed.

# TODO: Document how to use the generated fixture with Remove-ReparsePoints.
