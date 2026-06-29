# History

Version history for Remove-ReparsePoints.

Current project version: 0.7
Created: 2026-06-17

## v0.7

* adds a manual test fixture generator;
* creates regular files and directories, junctions, symbolic links, and hardlinks;
* includes a junction with additional filesystem attributes for manual testing.

## v0.6

* reports removed items only after a successful delete operation;
* reports failed removals with a clearer message and the underlying exception text;
* removes stale internal error-type comments from the removal logic.

## v0.5

* removes the interactive key press pause at the end of the script.

## v0.4

* uses preview-only mode by default;
* requires an explicit `-Remove` switch for actual deletion;
* replaces the previous `-Preview` switch with safer default behavior.

## v0.3

* adds `-Preview` mode;
* allows listing reparse points without changing attributes or removing filesystem entries.

## v0.2

* requires an explicit `-Path` parameter;
* removes the default current directory target.

## v0.1

* adds initial repository structure;
* adds the first rough version of `Remove-ReparsePoints.ps1`;
* adds basic project documentation and repository configuration files.
