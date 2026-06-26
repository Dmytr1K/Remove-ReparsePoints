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

# TODO: Define FileSystemLayout data structure.
# The layout should be a declarative description of file system entries.
# Each FileSystemEntry should describe one item to create:
# - Directory
# - File
# - Junction
# - DirectorySymlink
# - FileSymlink
# - Hardlink
#
# Notes:
# - The current use case is a manual test fixture.
# - The structure should not be limited to fixture-only naming.
# - The root directory can also be described as a FileSystemEntry.

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
