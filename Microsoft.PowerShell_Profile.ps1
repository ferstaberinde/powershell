#requires -modules oh-my-posh
Set-Theme agnoster

# Powershell Community Extensions
Import-Module Pscx

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

$OnlineTest = Read-Host -Prompt "Do you want the O365 cmdlets?"

If($OnlineTest -eq "y") {
    $Creds = Get-Credential -Message "Enter your O365 credentials"
    $session = New-PSSession -ConfigurationName Microsoft.Exchange `
                             -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
                             -Credential $Creds `
                             -Authentication Basic `
                             -AllowRedirection
    Import-PSSession $session
}

Write-Output "Powershell profile loaded!"