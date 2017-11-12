$SessionCreds = Get-Credential -Message "Enter your Azure Account Details"
Connect-AzureAD -Credential $SessionCreds

<#
$UnifiedGroups = Get-AzureADGroup
$UnifiedGroups    |   ForEach-Object {
    If ($_.SecurityEnabled -eq $False) {
        $_.displayName + " " + $_.mail
    }
}
#>

# This requires modules:
#   AzureAD
#   ImportExcel
Function Get-O365Groups {
    Connect-AzureAD
    $FileName = Read-Host -Prompt "Please enter CSV file name"
    $CsvName = $Filename + ".csv"
    $XlsName = $Filename + ".xlsx"
    $UnifiedGroups = Get-AzureADGroup | Where-Object {$_.SecurityEnabled -eq $False}
    $GroupOutput = @()
    $UnifiedGroups | ForEach-Object {
        $ThisGroup = New-Object -Type PSCustomObject -Property @{'displayName' = $_.displayName ; 'mail' = $_.mail}
        $GroupOutput += $ThisGroup
    }
    try {
        $GroupOutput | Export-Csv -Path "$CsvName" -NoTypeInformation
        $GroupOutput | Export-Excel -Path "$XlsName"
    } catch {
        $_.Exception.Message
    }
}

# Afterwards, to export to CSV
# Get-O365Groups | Export-Csv -Path ".\groups.csv" -NoTypeInformation

# Afterwards, to export to CSV with pipe Delimiter
# Get-O365Groups | Export-Csv -Path ".\groups.csv" -NoTypeInformation -Delimiter '|'


# This requires modules:
#   New PS Session
#   ImportExcel
Function Get-O365Groups {
# This block connects to the tenant and obtains the necessary cmdlets via an implcit remote session
<#
    $Creds = Get-Credential -Message "Enter your O365 credentials"
    $session = New-PSSession -ConfigurationName Microsoft.Exchange `
                             -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
                             -Credential $Creds `
                             -Authentication Basic `
                             -AllowRedirection
    Import-PSSession $session
#>
# This next block asks the user to name the output path and name (but NOT the extension)
    $FileName = Read-Host -Prompt "Please enter file path and name (EXCLUDE file extension)"
    $CsvName = $Filename + ".csv"
    $XlsName = $Filename + ".xlsx"
# This command returns all the Unified Groups (O365 Groups)
    $UnifiedGroups = Get-UnifiedGroup -SortBy "DisplayName"
# This block builds an array of custom objects, each of which has properties for 'DisplayName' and 'AccessType' 
    $GroupOutput = @()
    $UnifiedGroups | ForEach-Object {
        $ThisGroup = New-Object -Type PSCustomObject -Property @{'DisplayName' = $_.DisplayName ; 'AccessType' = $_.AccessType}
        $GroupOutput += $ThisGroup
    }
# This block attempts to output the array of custom objects into both CSV and XLSX files
    try {
        $GroupOutput | Export-Csv -Path "$CsvName" -NoTypeInformation
        $GroupOutput | Export-Excel -Path "$XlsName"
    } catch {
        $_.Exception.Message
    }
}