@{
  # Filter the notifications by severity level
  Severity            = @(
    'Error',
    'Warning'
  )

  # Load project-specific custom analyzer rules
  CustomRulePath      = @(
    '.\tools\PSScriptAnalyzerRules\Measure-VariablePascalCase.psm1'
  )

  # Keep all standard rules active together with custom rules
  IncludeDefaultRules = $true

  # Preserve the current script behavior while the baseline tests are added.
  # Remove each exclusion when the corresponding implementation work is complete.
  ExcludeRules        = @(
    'PSAvoidUsingWriteHost',
    'PSUseShouldProcessForStateChangingFunctions',
    'PSUseSingularNouns'
  )

  # Configure parameters for custom rule validation
  Rules               = @{
    PSUseCompatibleSyntax = @{
      Enable         = $true
      TargetVersions = @(
        '5.1'
      )
    }
  }
}
