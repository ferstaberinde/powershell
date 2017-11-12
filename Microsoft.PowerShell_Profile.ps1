#requires -modules oh-my-posh
Set-Theme agnoster

#PSReadline Stuff
Set-PSReadlineOption -TokenKind Command -ForeGroundColor Cyan
Set-PSReadlineOption -EditMode EMACS
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineKeyHandler -Key CTRL+V -Function Paste
Set-PSReadlineKeyHandler -Key CTRL+RightArrow -Function ForwardWord
Set-PSReadlineKeyHandler -Key CTRL+LeftArrow -Function BackwardWord
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

Write-Out "Powershell profile loaded!"