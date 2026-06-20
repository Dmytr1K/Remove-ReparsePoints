param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string]$Path,

  [switch]$Remove
)

Function Remove-ReparsePoints {
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Path,

    [switch]$Remove
  )

  Get-ChildItem -Path $Path -Force -ErrorAction Stop | ForEach-Object {
    $CurrentObject = $_
    If ($CurrentObject.Attributes -match 'ReparsePoint') {
      Try {
        If ($Remove) {
          If ($CurrentObject.Attributes -match 'ReadOnly') {
            $CurrentObject.Attributes -= 'ReadOnly'
          }
          If ($CurrentObject.Attributes -match 'System') {
            $CurrentObject.Attributes -= 'System'
          }
          Write-Host $CurrentObject.FullName
          $CurrentObject.Delete()
        }
        Else {
          Write-Host "Would remove: $($CurrentObject.FullName)"
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
        Remove-ReparsePoints -Path $CurrentObject.FullName -Remove:$Remove
      }
      Catch {
        Write-Host $CurrentObject.FullName
        Write-Host 'PSIsContainer Error!'
      }
    }
  }
}


Remove-ReparsePoints -Path $Path -Remove:$Remove

if ($Remove) {
  Write-Host 'Remove operation completed.'
}
else {
  Write-Host 'Preview completed.'
}
