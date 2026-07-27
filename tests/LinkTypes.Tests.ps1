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

  function New-TestSymbolicLink {
    param(
      [Parameter(Mandatory = $true)]
      [string] $Path,

      [Parameter(Mandatory = $true)]
      [string] $Target,

      [switch] $Directory
    )

    if ($Directory) {
      $Command = "mklink /D `"$Path`" `"$Target`""
    }
    else {
      $Command = "mklink `"$Path`" `"$Target`""
    }

    $CommandOutput = & cmd.exe /d /c $Command 2>&1

    if ($LASTEXITCODE -ne 0) {
      throw "mklink failed: $Command`n$CommandOutput"
    }
  }

  $SymbolicLinkProbeRoot = Join-Path $TestDrive 'SymbolicLinkCapabilityProbe'
  $SymbolicLinkProbeTarget = Join-Path $SymbolicLinkProbeRoot 'Target'
  $SymbolicLinkProbePath = Join-Path $SymbolicLinkProbeRoot 'Link'

  New-Item -ItemType Directory -Path $SymbolicLinkProbeTarget -Force | Out-Null

  try {
    New-TestSymbolicLink `
      -Path $SymbolicLinkProbePath `
      -Target $SymbolicLinkProbeTarget `
      -Directory

    $script:CanCreateSymbolicLinks = $true
    Remove-Item -LiteralPath $SymbolicLinkProbePath -Force
  }
  catch {
    $script:CanCreateSymbolicLinks = $false
  }
}

Describe 'Remove-ReparsePoints hardlink handling' {
  BeforeEach {
    $script:TestRoot = Join-Path $TestDrive ([Guid]::NewGuid().ToString())
    $script:ScanRoot = Join-Path $script:TestRoot 'ScanRoot'
    $script:OriginalFilePath = Join-Path $script:ScanRoot 'OriginalFile.txt'
    $script:HardlinkPath = Join-Path $script:ScanRoot 'HardlinkToOriginalFile.txt'
    $script:ExpectedFileContent = 'Hardlink content must survive removal mode.'

    New-Item -ItemType Directory -Path $script:ScanRoot -Force | Out-Null
    Set-Content -LiteralPath $script:OriginalFilePath -Value $script:ExpectedFileContent

    New-Item `
      -ItemType HardLink `
      -Path $script:HardlinkPath `
      -Target $script:OriginalFilePath | Out-Null

    $script:RemovalOutput = @(
      & $script:MainScriptPath -Path $script:ScanRoot -Remove 6>&1
    )
  }

  It 'does not remove a hardlink or its original file' {
    $script:OriginalFilePath |
    Should -Exist

    $script:HardlinkPath |
    Should -Exist
  }

  It 'preserves data shared by a hardlink and its original file' {
    Get-Content -LiteralPath $script:OriginalFilePath |
    Should -Be $script:ExpectedFileContent

    Get-Content -LiteralPath $script:HardlinkPath |
    Should -Be $script:ExpectedFileContent
  }
}

Describe 'Remove-ReparsePoints symbolic link handling' {
  BeforeEach {
    if (-not $script:CanCreateSymbolicLinks) {
      return
    }

    $script:TestRoot = Join-Path $TestDrive ([Guid]::NewGuid().ToString())
    $script:ScanRoot = Join-Path $script:TestRoot 'ScanRoot'
    $script:DirectoryTargetPath = Join-Path $script:TestRoot 'DirectoryTarget'
    $script:DirectoryTargetFilePath = Join-Path $script:DirectoryTargetPath 'TargetFile.txt'
    $script:FileTargetPath = Join-Path $script:TestRoot 'FileTarget.txt'
    $script:DirectorySymbolicLinkPath = Join-Path $script:ScanRoot 'DirectorySymbolicLink'
    $script:FileSymbolicLinkPath = Join-Path $script:ScanRoot 'FileSymbolicLink.txt'

    $script:ExpectedDirectoryTargetContent = 'Directory symbolic link target data.'
    $script:ExpectedFileTargetContent = 'File symbolic link target data.'

    New-Item -ItemType Directory -Path $script:ScanRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $script:DirectoryTargetPath | Out-Null

    Set-Content `
      -LiteralPath $script:DirectoryTargetFilePath `
      -Value $script:ExpectedDirectoryTargetContent

    Set-Content `
      -LiteralPath $script:FileTargetPath `
      -Value $script:ExpectedFileTargetContent

    New-TestSymbolicLink `
      -Path $script:DirectorySymbolicLinkPath `
      -Target $script:DirectoryTargetPath `
      -Directory

    New-TestSymbolicLink `
      -Path $script:FileSymbolicLinkPath `
      -Target $script:FileTargetPath

    $PreviewOutput = @(
      & $script:MainScriptPath -Path $script:ScanRoot 6>&1
    )
    $script:PreviewCandidatePaths = @(
      Get-PreviewCandidatePath -Output $PreviewOutput
    )

    $script:DirectorySymbolicLinkExistsAfterPreview = Test-Path -LiteralPath $script:DirectorySymbolicLinkPath
    $script:FileSymbolicLinkExistsAfterPreview = Test-Path -LiteralPath $script:FileSymbolicLinkPath

    $script:RemovalOutput = @(
      & $script:MainScriptPath -Path $script:ScanRoot -Remove 6>&1
    )
  }

  It 'reports directory and file symbolic links in preview mode' {
    if (-not $script:CanCreateSymbolicLinks) {
      Set-ItResult `
        -Skipped `
        -Because 'Creating symbolic links requires Developer Mode or administrator privileges.'
      return
    }

    $script:PreviewCandidatePaths |
    Should -Contain $script:DirectorySymbolicLinkPath

    $script:PreviewCandidatePaths |
    Should -Contain $script:FileSymbolicLinkPath
  }

  It 'preserves directory and file symbolic links in preview mode' {
    if (-not $script:CanCreateSymbolicLinks) {
      Set-ItResult `
        -Skipped `
        -Because 'Creating symbolic links requires Developer Mode or administrator privileges.'
      return
    }

    $script:DirectorySymbolicLinkExistsAfterPreview |
    Should -BeTrue

    $script:FileSymbolicLinkExistsAfterPreview |
    Should -BeTrue
  }

  It 'removes directory and file symbolic links in removal mode' {
    if (-not $script:CanCreateSymbolicLinks) {
      Set-ItResult `
        -Skipped `
        -Because 'Creating symbolic links requires Developer Mode or administrator privileges.'
      return
    }

    $script:DirectorySymbolicLinkPath |
    Should -Not -Exist

    $script:FileSymbolicLinkPath |
    Should -Not -Exist
  }

  It 'preserves symbolic link targets and their data' {
    if (-not $script:CanCreateSymbolicLinks) {
      Set-ItResult `
        -Skipped `
        -Because 'Creating symbolic links requires Developer Mode or administrator privileges.'
      return
    }

    $script:DirectoryTargetPath |
    Should -Exist

    $script:DirectoryTargetFilePath |
    Should -Exist

    $script:FileTargetPath |
    Should -Exist

    Get-Content -LiteralPath $script:DirectoryTargetFilePath |
    Should -Be $script:ExpectedDirectoryTargetContent

    Get-Content -LiteralPath $script:FileTargetPath |
    Should -Be $script:ExpectedFileTargetContent
  }
}
