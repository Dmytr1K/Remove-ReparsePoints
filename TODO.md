# TODO

Planned improvements for `Remove-ReparsePoints`.

## Near-term goal: establish a reliable project baseline

Bring the repository to a reliable quality baseline by adding the necessary development tooling, tests, CI, and technical documentation while preserving the existing script behavior as much as possible.

Apply only the engineering practices that fit this project. This repository is a compact technical utility for users who understand the filesystem operations involved, so its primary documentation should remain together in the repository root without an unnecessary documentation hierarchy.

The production script should not be refactored during this stage. Any required behavior change should be isolated, justified by a failing test or validation result, and reviewed separately.

### Repository and documentation structure

- Keep `README.md`, `HISTORY.md`, and `TODO.md` in the repository root.
- Do not add a separate development guide unless the technical material eventually becomes too large for the README.
- Add concise development prerequisites, validation commands, test instructions, and manual testing guidance directly to the README.
- Move the manual fixture generator into a purpose-specific `tools/ManualTesting` directory.
- Add proportionate documentation to all tracked PowerShell files:
  - use full comment-based help for user-facing scripts
  - document parameters, safety constraints, outputs, and examples where applicable
  - keep small supporting data files concise
- Review README, HISTORY, and TODO together for consistent terminology and links.

### Code analysis

- Add `PSScriptAnalyzerSettings.psd1`.
- Add the shared custom PascalCase variable naming rule used by the other PowerShell projects.
- Document any temporarily excluded analyzer rules that represent known implementation work:
  - `PSUseShouldProcessForStateChangingFunctions`
  - `PSAvoidUsingWriteHost`
  - `PSUseSingularNouns`
- Remove temporary analyzer exclusions when the corresponding implementation work is completed.

### Automated tests for the current behavior

- Add the initial Pester 5 test setup before refactoring the main script.
- Keep test concerns in separate files as the suite grows:
  - `ProjectStructure.Tests.ps1`
  - `PreviewMode.Tests.ps1`
  - `Removal.Tests.ps1`
  - `PathSafety.Tests.ps1`
  - `ManualTestFixture.Tests.ps1`
- Add project structure and syntax validation tests.
- Add characterization tests for the current preview mode.
- Capture the current set of discovered reparse points without making incidental console formatting part of the long-term contract.
- Verify that preview mode does not modify regular files, directories, links, or attributes.
- Add characterization tests for explicit `-Remove` behavior in isolated temporary directories.
- Add tests for finding and removing:
  - junctions
  - directory symbolic links
  - file symbolic links
  - junctions with additional filesystem attributes
- Add a test that hardlinks are not treated as reparse points.
- Verify that regular files and regular directories are preserved.
- Verify that traversal continues through regular directories but does not recurse into reparse-point directories.
- Keep automated test fixtures isolated from the manual fixture generator initially.
- Extract shared test helpers only after meaningful duplication appears.
- Define a predictable skip strategy for symbolic-link tests when the environment does not grant link-creation privileges.

### Continuous integration

- Add a Windows PowerShell 5.1 GitHub Actions workflow for pushes and pull requests targeting `main`.
- Install the pinned development dependencies in CI.
- Run the Pester suite in CI.
- Run PSScriptAnalyzer with the project settings and custom rules in CI.
- Keep the workflow focused on validation; do not add deployment or release automation yet.

### Technical documentation

- Document the exact current meaning of preview mode and `-Remove`.
- Document which filesystem objects are currently detected by the implementation.
- Document that the current implementation is an early version and that reparse-point classification will be tightened later.
- Expand manual fixture instructions with expected preview and removal results.
- Add badges only after the corresponding CI and validation steps exist.
- Prepare short scripted terminal demonstrations using disposable test data:
  - previewing detected reparse points
  - explicitly removing supported test links
  - running the automated tests
- Store finished demonstration assets in a compact repository-level assets directory rather than creating a separate documentation hierarchy.
- Avoid private, machine-specific, or destructive real-world paths in demonstrations.

### Repository presentation

- Review the repository description after the safety model and current scope are documented clearly.
- Add focused repository topics such as PowerShell, Windows, filesystem, reparse-points, junctions, and symbolic-links.
- Verify that no generated fixtures, test output, local notes, or machine-specific data are tracked.
- Review the repository from a clean clone before treating the baseline as complete.

## Later goal: improve the script implementation

Improve the safety model, architecture, output, and supported behavior only after the baseline tests and CI protect the current behavior.

### Path handling and destructive-operation safety

- Resolve and normalize the input path before traversal.
- Use literal-path operations so wildcard characters are not interpreted unexpectedly.
- Require the target to exist and be a directory.
- Reject empty or whitespace-only paths.
- Add code-level protection for dangerous removal targets, including:
  - a drive root
  - the Windows directory
  - the active user profile
  - the repository root
- Decide whether preview mode may inspect paths that removal mode must reject.
- Add `SupportsShouldProcess` and support standard `-WhatIf` and `-Confirm` behavior.
- Preserve preview-only operation as the default even after `ShouldProcess` is introduced.

### Windows reparse-point semantics research

- Review the official Windows documentation before finalizing classification and removal behavior.
- Document the filesystem model for files and directories that carry reparse data.
- Study the differences between:
  - junctions and mount points
  - directory symbolic links
  - file symbolic links
  - other reparse tags, including non-link reparse points
- Determine how directory enumeration behaves when a reparse-point directory is opened.
- Determine whether a reparse-point directory namespace is redirected completely to its target or whether any supported reparse type can expose a combination of local and target entries.
- Determine where a newly created child entry is stored when it is created through a reparse-point directory path.
- Determine whether local child entries can exist behind a directory reparse point and, if so, whether they can be inspected without following the reparse target.
- Study behavior for:
  - broken or unavailable targets
  - relative and absolute symbolic-link targets
  - nested reparse points
  - targets that lead back to an ancestor and create traversal loops
  - reparse points with additional read-only, hidden, or system attributes
- Verify the documented behavior with disposable controlled fixtures instead of relying only on assumptions.
- Record the research conclusions in the technical documentation before enabling type-based removal filters.
- Use the research results to define which metadata discovery must return and which types removal may support safely.

### Discovery, classification, filtering, and removal pipeline

- Split the current traversal and removal logic only after characterization coverage is in place.
- Implement the refactoring in this order:
  1. discover reparse points without modifying them
  2. classify every discovered reparse point
  3. filter the classified results according to an explicit selection policy
  4. preview or remove only the selected results
- Make discovery return a collection of structured PowerShell objects rather than formatted text or one aggregate hash table.
- Define discovery and classification properties such as:
  - `Path`
  - `ReparsePointType`
  - `ReparseTag` where available
  - `Target` where available
  - `Supported`
  - `Selected`
  - `SelectionReason`
- Keep the returned objects unformatted so callers can inspect, filter, export, or display them as needed.
- Use table output only as a presentation layer for interactive console use.
- Distinguish supported link types from other filesystem objects that carry the `ReparsePoint` attribute.
- Define an explicit supported-type policy for:
  - junctions
  - directory symbolic links
  - file symbolic links
- Decide how mount points and other reparse tags should be reported.
- Skip unknown or unsupported reparse types by default rather than removing them.
- Add filtering only after discovery and classification results are stable.
- Decide whether filters should select specific types, all supported types, or an explicitly requested wider set.
- Make preview and removal consume the same filtered collection so they cannot select different items accidentally.
- Ensure removal receives already discovered and selected objects instead of independently traversing the tree a second time.
- Keep the user-facing script as a thin entry point.
- Decide whether reusable logic should live in dot-sourced scripts or a small module.
- Use singular approved nouns for internal PowerShell functions.
- Replace string matching on filesystem attributes with explicit flag operations.
- Preserve the rule that traversal must not follow reparse-point directories.

### Output and error handling

- Replace `Write-Host`-only reporting with structured result objects.
- Define result properties such as path, detected type, target, requested action, status, and error details.
- Use information, verbose, warning, and error streams consistently.
- Report a clear final summary for preview and removal runs.
- Decide when an individual failure should continue the run and when the script should terminate.
- Ensure partial failures are visible to both interactive users and automation.

### Expanded regression coverage

- Add tests for rejected dangerous paths.
- Add tests showing that wildcard characters are handled literally.
- Add tests for unknown or unsupported reparse types where practical.
- Add controlled tests for directory enumeration through each supported directory reparse-point type.
- Add tests that verify whether entries observed through a reparse-point path belong to the target, the reparse-point directory itself, or another documented namespace behavior.
- Add tests showing where files created through a reparse-point directory path are stored.
- Add tests for broken targets, nested reparse points, and traversal loops.
- Add tests that discovery returns one structured object for each detected reparse point.
- Add tests for classification metadata and supported-type decisions.
- Add tests showing that filters select only the requested classified types.
- Add tests showing that preview and removal consume the same selected collection.
- Add tests showing that removal does not affect discovered objects excluded by the filter.
- Add tests for inaccessible directories and failed deletions.
- Add tests for nested directory trees and multiple detected links.
- Add tests for result objects, summaries, warnings, and error behavior.
- Verify that read-only, hidden, and system attributes are handled only on the link being removed.

### Manual test fixture generator

- Add safety checks for dangerous fixture root paths:
  - drive root
  - Windows directory
  - active user profile
  - repository root
- Replace command-string construction for link creation with a safer invocation approach where Windows PowerShell 5.1 permits it.
- Define cleanup behavior for a partially created fixture.
- Add optional recreate behavior for an existing fixture root:
  - decide whether to allow an existing empty directory
  - decide whether to support removing and recreating the fixture root
  - require an explicit `-Force` switch for destructive recreate behavior
- Add cleanup or reset behavior only if it remains explicit and safely scoped.
- Consider adding a cleanup option to remove the fixture after testing.

### Compatibility

- Validate supported behavior on Windows 10 and Windows 11.
- Keep Windows PowerShell 5.1 as the initial supported runtime baseline.
- Evaluate PowerShell 7 compatibility separately without delaying the Windows PowerShell 5.1 milestones.

## Versioning, verification, and release milestones

Keep versioning simple and tag only meaningful project milestones rather than every documentation or maintenance change.

The versions already recorded in HISTORY through v0.7 remain historical development versions. Do not create retrospective tags for them unless a specific need appears.

Starting with `v0.8.0`, use the three-part `MAJOR.MINOR.PATCH` format consistently and leave the earlier HISTORY entries unchanged.

### v0.8.0: reliable project baseline

Use `v0.8.0` as the first Git tag after the near-term baseline is complete:

- repository and tool structure is organized
- development dependencies are pinned and install reproducibly
- characterization tests protect the current behavior
- CI runs the tests and code analysis on Windows PowerShell 5.1
- technical usage, safety, testing, and maintenance instructions are current
- the production script behavior remains substantially unchanged

This milestone establishes a trustworthy starting point for implementation refactoring.

### v0.9.0: refactored processing pipeline

Use `v0.9.0` after the new processing model is implemented and covered:

- discovery returns structured objects
- reparse points are classified
- filtering operates on classified results
- preview and removal consume the same selected collection
- supported and unsupported types follow an explicit policy
- path protection, `ShouldProcess`, and the new error model are implemented
- the original behavior has been compared against the characterization baseline and intentional differences are documented

This remains a pre-1.0 milestone while edge cases, compatibility, and final manual validation are completed.

### v1.0.0: first stable utility release

Use `v1.0.0` when the utility has a clearly documented and validated public contract:

- supported reparse-point types and default filtering behavior are stable
- unknown or unsupported types are handled safely
- destructive operations are protected by path validation and standard PowerShell confirmation semantics
- structured output and error behavior are documented and tested
- the complete automated suite and code analysis pass in CI
- supported manual fixture scenarios pass on the target Windows environments
- no high-priority safety or correctness work remains in TODO
- README and HISTORY describe the final v1.0.0 behavior accurately

### Release verification checklist

Apply the same compact checklist before every tagged milestone:

- confirm the intended milestone scope is complete
- run the pinned development dependency setup from a clean environment
- run the full Pester suite
- run PSScriptAnalyzer with the project settings and custom rules
- complete the relevant manual fixture scenarios in preview and removal modes
- verify the expected output, preserved files, removed links, and error cases
- verify the repository from a clean clone
- confirm that no generated fixtures, test output, local notes, secrets, or machine-specific data are tracked
- update README and HISTORY for the release behavior
- confirm the exact release commit passes CI on `main`
- create an annotated `vX.Y.Z` tag on that verified commit
- publish a concise GitHub Release describing the milestone, validation, and known limitations

### Versions after v1.0.0

Use a minimal semantic-versioning policy:

- patch versions for backward-compatible fixes
- minor versions for backward-compatible features or newly supported reparse-point types
- major versions only for intentional breaking changes to parameters, default selection behavior, structured output, or safety policy
- do not create a release tag for documentation-only or internal maintenance commits unless they accompany a user-visible release

After v1.0.0, reassess the pinned-repository selection and add the project to the GitHub Profile README as a stable featured utility.
