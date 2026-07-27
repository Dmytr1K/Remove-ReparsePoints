#requires -Version 5.1

BeforeAll {
  $ProjectRoot = Split-Path -Parent $PSScriptRoot
  $script:MainScriptPath = Join-Path $ProjectRoot 'Remove-ReparsePoints.ps1'
}

Describe 'Remove-ReparsePoints removal mode' {
  BeforeEach {
    $script:TestRoot = Join-Path $TestDrive ([Guid]::NewGuid().ToString())
    $script:ScanRoot = Join-Path $script:TestRoot 'ScanRoot'
    $script:RegularDirectoryPath = Join-Path $script:ScanRoot 'RegularDirectory'
    $script:NestedDirectoryPath = Join-Path $script:RegularDirectoryPath 'NestedDirectory'
    $script:RegularFilePath = Join-Path $script:RegularDirectoryPath 'RegularFile.txt'

    $script:ExternalTargetPath = Join-Path $script:TestRoot 'ExternalTarget'
    $script:ExternalTargetFilePath = Join-Path $script:ExternalTargetPath 'TargetFile.txt'
    $script:SecondaryTargetPath = Join-Path $script:TestRoot 'SecondaryTarget'

    $script:RootJunctionPath = Join-Path $script:ScanRoot 'JunctionToExternalTarget'
    $script:NestedJunctionPath = Join-Path $script:NestedDirectoryPath 'NestedJunctionToExternalTarget'
    $script:AttributedJunctionPath = Join-Path $script:ScanRoot 'JunctionWithAttributes'
    $script:HiddenJunctionPath = Join-Path $script:ExternalTargetPath 'JunctionInsideExternalTarget'

    New-Item -ItemType Directory -Path $script:NestedDirectoryPath -Force | Out-Null
    New-Item -ItemType Directory -Path $script:ExternalTargetPath | Out-Null
    New-Item -ItemType Directory -Path $script:SecondaryTargetPath | Out-Null

    $script:ExpectedRegularFileContent = 'Regular file content must survive removal mode.'
    $script:ExpectedTargetFileContent = 'Target data must survive removal of a junction.'

    Set-Content `
      -LiteralPath $script:RegularFilePath `
      -Value $script:ExpectedRegularFileContent

    Set-Content `
      -LiteralPath $script:ExternalTargetFilePath `
      -Value $script:ExpectedTargetFileContent

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
      -Path $script:AttributedJunctionPath `
      -Target $script:ExternalTargetPath | Out-Null

    New-Item `
      -ItemType Junction `
      -Path $script:HiddenJunctionPath `
      -Target $script:SecondaryTargetPath | Out-Null

    $AttributedJunction = Get-Item -LiteralPath $script:AttributedJunctionPath -Force
    $AttributedJunction.Attributes =
      $AttributedJunction.Attributes -bor
      [System.IO.FileAttributes]::ReadOnly -bor
      [System.IO.FileAttributes]::Hidden -bor
      [System.IO.FileAttributes]::System

    $script:RemovalOutput = @(
      & $script:MainScriptPath -Path $script:ScanRoot -Remove 6>&1
    )
  }

  It 'removes a junction in the scanned root' {
    $script:RootJunctionPath |
    Should -Not -Exist
  }

  It 'traverses regular directories and removes a nested junction' {
    $script:NestedJunctionPath |
    Should -Not -Exist
  }

  It 'removes a junction with additional filesystem attributes' {
    $script:AttributedJunctionPath |
    Should -Not -Exist
  }

  It 'preserves regular files, directories, and file content' {
    $script:RegularDirectoryPath |
    Should -Exist

    $script:NestedDirectoryPath |
    Should -Exist

    $script:RegularFilePath |
    Should -Exist

    Get-Content -LiteralPath $script:RegularFilePath |
    Should -Be $script:ExpectedRegularFileContent
  }

  It 'preserves the junction target and its data' {
    $script:ExternalTargetPath |
    Should -Exist

    $script:ExternalTargetFilePath |
    Should -Exist

    Get-Content -LiteralPath $script:ExternalTargetFilePath |
    Should -Be $script:ExpectedTargetFileContent
  }

  It 'does not remove a junction located inside an external target' {
    $script:HiddenJunctionPath |
    Should -Exist
  }
}
