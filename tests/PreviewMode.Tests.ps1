#requires -Version 5.1

BeforeAll {
  $ProjectRoot = Split-Path -Parent $PSScriptRoot
  $script:MainScriptPath = Join-Path $ProjectRoot 'Remove-ReparsePoints.ps1'

  function Get-PreviewCandidatePath {
    param(
      [Parameter(Mandatory = $true)]
      [object[]] $Output
    )

    foreach ($OutputItem in $Output) {
      $OutputText = $OutputItem.ToString()

      if ($OutputText -match '^Would remove: (.+)$') {
        $Matches[1]
      }
    }
  }
}

Describe 'Remove-ReparsePoints preview mode' {
  BeforeEach {
    $script:TestRoot = Join-Path $TestDrive ([Guid]::NewGuid().ToString())
    $script:ScanRoot = Join-Path $script:TestRoot 'ScanRoot'
    $script:RegularDirectoryPath = Join-Path $script:ScanRoot 'RegularDirectory'
    $script:NestedDirectoryPath = Join-Path $script:RegularDirectoryPath 'NestedDirectory'
    $script:RegularFilePath = Join-Path $script:RegularDirectoryPath 'RegularFile.txt'

    $script:ExternalTargetPath = Join-Path $script:TestRoot 'ExternalTarget'
    $script:SecondaryTargetPath = Join-Path $script:TestRoot 'SecondaryTarget'
    $script:RootJunctionPath = Join-Path $script:ScanRoot 'JunctionToExternalTarget'
    $script:NestedJunctionPath = Join-Path $script:NestedDirectoryPath 'NestedJunctionToExternalTarget'
    $script:HiddenJunctionPath = Join-Path $script:ExternalTargetPath 'JunctionInsideExternalTarget'

    New-Item -ItemType Directory -Path $script:NestedDirectoryPath -Force | Out-Null
    New-Item -ItemType Directory -Path $script:ExternalTargetPath | Out-Null
    New-Item -ItemType Directory -Path $script:SecondaryTargetPath | Out-Null

    $script:ExpectedFileContent = 'Regular file content must remain unchanged in preview mode.'
    Set-Content -LiteralPath $script:RegularFilePath -Value $script:ExpectedFileContent

    New-Item `
      -ItemType Junction `
      -Path $script:RootJunctionPath `
      -Target $script:ExternalTargetPath | Out-Null

    New-Item `
      -ItemType Junction `
      -Path $script:NestedJunctionPath `
      -Target $script:ExternalTargetPath | Out-Null

    New-Item `
      -ItemType Junction `
      -Path $script:HiddenJunctionPath `
      -Target $script:SecondaryTargetPath | Out-Null

    $script:InitialRegularFileAttributes = (Get-Item -LiteralPath $script:RegularFilePath).Attributes
    $script:InitialRootJunctionAttributes = (Get-Item -LiteralPath $script:RootJunctionPath).Attributes

    $script:PreviewOutput = @(
      & $script:MainScriptPath -Path $script:ScanRoot 6>&1
    )
    $script:PreviewCandidatePaths = @(
      Get-PreviewCandidatePath -Output $script:PreviewOutput
    )
  }

  It 'reports a junction in the scanned root' {
    $script:PreviewCandidatePaths |
    Should -Contain $script:RootJunctionPath
  }

  It 'traverses regular directories and reports a nested junction' {
    $script:PreviewCandidatePaths |
    Should -Contain $script:NestedJunctionPath
  }

  It 'does not recurse into a reparse-point directory' {
    $script:PreviewCandidatePaths |
    Should -Not -Contain $script:HiddenJunctionPath
  }

  It 'does not report regular files or directories as removal candidates' {
    $script:PreviewCandidatePaths |
    Should -Not -Contain $script:RegularDirectoryPath

    $script:PreviewCandidatePaths |
    Should -Not -Contain $script:RegularFilePath
  }

  It 'preserves the discovered junctions' {
    $script:RootJunctionPath |
    Should -Exist

    $script:NestedJunctionPath |
    Should -Exist
  }

  It 'preserves regular files and their content' {
    $script:RegularFilePath |
    Should -Exist

    Get-Content -LiteralPath $script:RegularFilePath |
    Should -Be $script:ExpectedFileContent
  }

  It 'preserves file and junction attributes' {
    (Get-Item -LiteralPath $script:RegularFilePath).Attributes |
    Should -Be $script:InitialRegularFileAttributes

    (Get-Item -LiteralPath $script:RootJunctionPath).Attributes |
    Should -Be $script:InitialRootJunctionAttributes
  }
}
