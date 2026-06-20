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
          $CurrentObject.Delete()
          Write-Host "Removed: $($CurrentObject.FullName)"
        }
        Else {
          Write-Host "Would remove: $($CurrentObject.FullName)"
        }
      }
      Catch {
        Write-Host "Failed to remove: $($CurrentObject.FullName)"
        Write-Host $_.Exception.Message
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
  Write-Host 'Remove operation finished.'
}
else {
  Write-Host 'Preview completed.'
}
