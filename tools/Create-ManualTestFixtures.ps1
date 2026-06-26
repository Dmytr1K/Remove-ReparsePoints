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

# TODO: Add safety checks for dangerous root paths.
# Examples: drive root, Windows directory, active user profile, or repository root.

if (Test-Path -LiteralPath $RootPath) {
  throw "Fixture root already exists: $RootPath. Choose a new path or remove the existing directory manually."
}

# TODO: Add optional recreate behavior for an existing fixture root.
# Current behavior: stop if the fixture root already exists.
# Later, decide whether to support:
# - allowing an empty existing directory
# - removing and recreating the fixture root
# - requiring an explicit -Force switch

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
    }
    [ordered]@{
      Type         = 'File'
      RelativePath = 'RegularDirectory\RegularFile.txt'
      Content      = 'Regular file used by manual Remove-ReparsePoints tests.'
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

# TODO: Add validation for unsupported item types.

# TODO: Add validation for missing required fields.

# TODO: Create fixture root directory if it does not exist.

# TODO: Add basic processor for regular directories.

# TODO: Add basic processor for regular files.

# TODO: Add support for attributes.

# TODO: Add processor for junctions.

# TODO: Add processor for symbolic links.

# TODO: Add processor for hardlinks.

# TODO: Add clearer output messages.

# TODO: Add cleanup/reset behavior later if needed.

# TODO: Document how to use the generated fixture with Remove-ReparsePoints.
