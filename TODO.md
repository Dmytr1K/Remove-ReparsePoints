# TODO

Planned later improvements for project Remove-ReparsePoints.

## Main script logic

* Split finding and removing logic.
* Further improve output and error handling.

## Manual test fixture generator

* Add safety checks for dangerous fixture root paths.
  * Drive root.
  * Windows directory.
  * Active user profile.
  * Repository root.

* Add optional recreate behavior for an existing fixture root.
  * Decide whether to allow an existing empty directory.
  * Decide whether to support removing and recreating the fixture root.
  * Require an explicit `-Force` switch if destructive recreate behavior is added.

* Add cleanup/reset behavior if needed.

* Consider adding a cleanup option to remove the fixture after testing.
