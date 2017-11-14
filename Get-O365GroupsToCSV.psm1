Function Get-O365GroupsToCSV {
# This block ensures that if web access is via a proxy, that we always send the current users' network credentials (in case proxy requires it)
    $global:wc                   = New-Object Net.WebClient
    $global:wc.Proxy.Credentials = [Net.CredentialCache]::DefaultNetworkCredentials
# This block connects to the tenant and obtains the necessary cmdlets via an implcit remote session (but if doesn't create a NEW session if one exists)
    try {
        $CurrentSessions = Get-PSSession
        if(-not $CurrentSessions.ConfigurationName -contains "Microsoft.Exchange") {
            $Creds = Get-Credential -Message "Enter your O365 credentials"
            $session = New-PSSession -ConfigurationName Microsoft.Exchange `
                                 -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
                                 -Credential $Creds `
                                 -Authentication Basic `
                                 -AllowRedirection
            Import-PSSession $session -DisableNameChecking | Out-Null
        }
    } catch {
        $_.Exception.Message
        return
    }
# This next block asks the user to name the output path and name (but NOT the extension)
    $FileName = Read-Host -Prompt "Please enter file path and name (EXCLUDE file extension)"
    $CsvName = $Filename + ".csv"
# This command returns all the Unified Groups (O365 Groups)
    $UnifiedGroups = Get-UnifiedGroup
# This block builds an array of custom objects, each of which has members for all the Group properties available via the Get-UnifiedGroup cmdlet 
    $GroupOutput = @()
    $UnifiedGroups | ForEach-Object {
        $ThisGroup = New-Object -Type PSCustomObject
        $ThisGroup | Add-Member -NotePropertyName DisplayName -NotePropertyValue $_.DisplayName
        $ThisGroup | Add-Member -NotePropertyName AccessType -NotePropertyValue $_.AccessType
        $ThisGroup | Add-Member -NotePropertyName Description -NotePropertyValue $_.Notes
        $ThisGroup | Add-Member -NotePropertyName Owners -NotePropertyValue $_.ManagedBy
        $ThisGroup | Add-Member -NotePropertyName MembersCount -NotePropertyValue $_.GroupMemberCount 
        $ThisGroup | Add-Member -NotePropertyName ExtMembersCount -NotePropertyValue $_.GroupExternalMemberCount
        # $ThisGroup | Add-Member -NotePropertyName Email -NotePropertyValue $_.EmailAddresses
        $ThisGroup | Add-Member -NotePropertyName PrimaryEmail -NotePropertyValue $_.PrimarySmtpAddress
        $ThisGroup | Add-Member -NotePropertyName AutoSub -NotePropertyValue $_.AutoSubscribeNewMembers
        $GroupOutput += $ThisGroup
    }
# This block attempts to output the array of custom objects into a CSV file, then closes the PSSession IF it was created by this script
    try {
        $GroupOutput = $GroupOutput | Sort-Object -Property DisplayName
        $GroupOutput | Export-Csv -Path "$CsvName" -NoTypeInformation
    } catch {
        $_.Exception.Message
    } finally {
        if($session) {
            Remove-PSSession $session
        }
    }
}
