param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string]$Path,

  [switch]$Preview
)

Function Remove-ReparsePoints {
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Path,

    [switch]$Preview
  )

  Get-ChildItem -Path $Path -Force -ErrorAction Stop | ForEach-Object {
    $CurrentObject = $_
    If ($CurrentObject.Attributes -match 'ReparsePoint') {
      Try {
        If ($Preview) {
          Write-Host "Would remove: $($CurrentObject.FullName)"
        }
        Else {
          If ($CurrentObject.Attributes -match 'ReadOnly') {
            $CurrentObject.Attributes -= 'ReadOnly'
          }
          If ($CurrentObject.Attributes -match 'System') {
            $CurrentObject.Attributes -= 'System'
          }
          Write-Host $CurrentObject.FullName
          $CurrentObject.Delete()
        }
      }
      Catch {
        # [System.IO.IOException]
        Write-Host $CurrentObject.FullName
        Write-Host 'ReparsePoint Error!'
      }
    }
    ElseIf ($CurrentObject.PSIsContainer) {
      Try {
        Remove-ReparsePoints -Path $CurrentObject.FullName -Preview:$Preview
      }
      Catch {
        Write-Host $CurrentObject.FullName
        Write-Host 'PSIsContainer Error!'
      }
    }
  }
}


Remove-ReparsePoints -Path $Path -Preview:$Preview

if ($Preview) {
  Write-Host 'Preview completed.'
}
else {
  Write-Host 'Remove operation completed.'
}

$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
