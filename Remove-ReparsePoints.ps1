#requires -Version 5.1

# Remove-ReparsePoints.ps1
#
# Finds reparse points in a directory tree and optionally removes them.
#
# By default, the script runs in preview mode.
# Actual removal requires the explicit -Remove switch.

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $Path,

  [switch] $Remove
)

function Remove-ReparsePoints {
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Path,

    [switch] $Remove
  )

  Get-ChildItem -Path $Path -Force -ErrorAction Stop | ForEach-Object {
    $CurrentObject = $_

    if ($CurrentObject.Attributes -match 'ReparsePoint') {
      try {
        if ($Remove) {
          if ($CurrentObject.Attributes -match 'ReadOnly') {
            $CurrentObject.Attributes -= 'ReadOnly'
          }

          if ($CurrentObject.Attributes -match 'System') {
            $CurrentObject.Attributes -= 'System'
          }

          $CurrentObject.Delete()
          Write-Host "Removed: $($CurrentObject.FullName)"
        }
        else {
          Write-Host "Would remove: $($CurrentObject.FullName)"
        }
      }
      catch {
        Write-Host "Failed to remove: $($CurrentObject.FullName)"
        Write-Host $_.Exception.Message
      }
    }
    elseif ($CurrentObject.PSIsContainer) {
      try {
        Remove-ReparsePoints -Path $CurrentObject.FullName -Remove:$Remove
      }
      catch {
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
