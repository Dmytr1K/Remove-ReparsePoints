<#
.SYNOPSIS
Checks that project variable names use PascalCase.

.DESCRIPTION
Reports variables that do not use PascalCase while ignoring PowerShell automatic variables and supported scoped variable prefixes.
#>
function Measure-VariablePascalCase {
  [CmdletBinding()]
  [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
  param(
    [Parameter(Mandatory = $true)]
    [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
  )

  if ($null -ne $ScriptBlockAst.Parent) {
    return
  }

  $IgnoredVariables = @(
    '_'
    '?'
    '^'
    '$'
    'args'
    'false'
    'foreach'
    'input'
    'null'
    'switch'
    'this'
    'true'
    'ConsoleFileName'
    'Error'
    'Event'
    'EventArgs'
    'EventSubscriber'
    'ExecutionContext'
    'HOME'
    'Host'
    'IsCoreCLR'
    'IsLinux'
    'IsMacOS'
    'IsWindows'
    'LASTEXITCODE'
    'Matches'
    'MyInvocation'
    'NestedPromptLevel'
    'PID'
    'PROFILE'
    'PSBoundParameters'
    'PSCmdlet'
    'PSCommandPath'
    'PSCulture'
    'PSDebugContext'
    'PSEdition'
    'PSHOME'
    'PSItem'
    'PSScriptRoot'
    'PSStyle'
    'PSUICulture'
    'PSVersionTable'
    'PWD'
    'ShellId'
    'StackTrace'
  )

  $Variables = $ScriptBlockAst.FindAll(
    {
      param($Ast)

      $Ast -is [System.Management.Automation.Language.VariableExpressionAst]
    },
    $true
  )

  foreach ($Variable in $Variables) {
    $DisplayName = $Variable.VariablePath.UserPath
    $NameForCheck = $DisplayName

    if ([string]::IsNullOrWhiteSpace($NameForCheck)) {
      continue
    }

    if ($NameForCheck -match '^(script|global|local|private):(.+)$') {
      $NameForCheck = $Matches[2]
    }
    elseif ($NameForCheck -match ':') {
      continue
    }

    if ($NameForCheck -in $IgnoredVariables) {
      continue
    }

    if ($NameForCheck -cnotmatch '^[A-Z][A-Za-z0-9]*$') {
      [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]::new(
        "Variable '$DisplayName' should use PascalCase.",
        $Variable.Extent,
        'Measure-VariablePascalCase',
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticSeverity]::Warning,
        $null
      )
    }
  }
}

Export-ModuleMember -Function Measure-VariablePascalCase
