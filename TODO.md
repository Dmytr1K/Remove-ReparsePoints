# TODO

Planned later improvements for project `Remove-ReparsePoints`.

## Tests

- Add initial Pester test setup before refactoring the main script.

- Add automated tests for preview mode.

- Add automated tests for explicit `-Remove` behavior.

- Add tests for finding and removing:
  - junctions
  - directory symbolic links
  - file symbolic links
  - junctions with additional filesystem attributes

- Add a test that hardlinks are not treated as reparse points.

- Decide whether automated tests should reuse the manual fixture generator or create their own temporary test fixtures.

## Main script logic

- Split finding and removing logic after initial Pester coverage is in place.

- Further improve output and error handling.

## Manual test fixture generator

- Add safety checks for dangerous fixture root paths:
  - drive root
  - Windows directory
  - active user profile
  - repository root

- Add optional recreate behavior for an existing fixture root:
  - decide whether to allow an existing empty directory
  - decide whether to support removing and recreating the fixture root
  - require an explicit `-Force` switch if destructive recreate behavior is added

- Add cleanup/reset behavior if needed.

- Consider adding a cleanup option to remove the fixture after testing.
