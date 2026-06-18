param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string]$Path
)

Function Remove-ReparsePoints {
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Path
  )

  Get-ChildItem -Path $Path -Force -ErrorAction Stop | ForEach-Object {
    $CurrentObject = $_
    If ($CurrentObject.Attributes -match 'ReparsePoint') {
      Try {
        If ($CurrentObject.Attributes -match 'ReadOnly') {
          $CurrentObject.Attributes -= 'ReadOnly'
        }
        If ($CurrentObject.Attributes -match 'System') {
          $CurrentObject.Attributes -= 'System'
        }
        Write-Host $CurrentObject.FullName
        $CurrentObject.Delete()
      }
      Catch {
        # [System.IO.IOException]
        Write-Host $CurrentObject.FullName
        Write-Host 'ReparsePoint Error!'
      }
    }
    ElseIf ($CurrentObject.PSIsContainer) {
      Try {
        Remove-ReparsePoints -Path $CurrentObject.FullName
      }
      Catch {
        Write-Host $CurrentObject.FullName
        Write-Host 'PSIsContainer Error!'
      }
    }
  }
}


Remove-ReparsePoints -Path $Path

Write-Host 'All reparse points deleted!!!'
$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
