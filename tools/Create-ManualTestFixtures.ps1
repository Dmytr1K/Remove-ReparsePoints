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
# - It should never target important real data.
# - The fixture root should be explicit and easy to delete.

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

# TODO: Add fixture root path.
# The root path should be explicit.
# Do not default to a dangerous location.

# TODO: Check whether fixture root already exists.
# Decide whether to:
# - stop with a warning
# - remove and recreate
# - require explicit -Force later

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
