Function Test-Append {
$Filename = Read-Host -Prompt "Please enter file path and name (INCLUDE file extension)"
$Message0 = Read-Host -Prompt "Please enter the first message"
$Message1 = Read-Host -Prompt "Please enter the first message"
$Message0 > $Filename
$Message1 >> $Filename
}