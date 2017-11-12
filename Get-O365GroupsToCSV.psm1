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
# This block builds an array of custom objects, each of which has properties for 'DisplayName' and 'AccessType' 
    $GroupOutput = @()
    $UnifiedGroups | ForEach-Object {
        $ThisGroup = New-Object -Type PSCustomObject -Property @{'DisplayName' = $_.DisplayName ; 'AccessType' = $_.AccessType}
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
