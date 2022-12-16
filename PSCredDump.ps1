# Based on Lee Holmes posts. Great stuff that you should read :)  https://www.leeholmes.com/extracting-forensic-script-content-from-powershell-process-dumps/ https://www.leeholmes.com/extracting-activity-history-from-powershell-process-dumps/
param([switch]$aztokens = $false,$dump)

if(-not($dump)){
    Write-Host "ERROR. The Powershell Dump was not defined"
    Exit
}

if (-not(Test-Path -Path $dump)) {
    Write-Host "ERROR. The Powershell dump was not found."
    Exit
 }
if (-not(Get-Module -ListAvailable -Name windbg)) {
    Write-Host "ERROR. Windbg module is not installed, install with install-module windbg"
    Exit
} 
if ($aztokens){
    Write-Host "You have chosen to only display the Azure related tokens"
}

Connect-DbgSession -ArgumentList "-z $dump"

$allReferences = dbg !dumpheap -type HistoryInfo
$HistoryInfoaddr = 0
$finalCommandStructure = @()

foreach ($line in $allReferences){
if($line -like "*Microsoft.PowerShell.Commands.HistoryInfo"){
$HistoryInfoaddr =  $line.Split(" ")[0]
}
}
$commandListAddresses = dbg !DumpHeap /d -mt $HistoryInfoaddr
foreach ($line in $commandListAddresses){
    $separateHistory = dbg !DumpObj /d $line.Split(" ")[0]
    foreach ($section in $separateHistory){
        if($section -like "*_cmdline"){
            $finalcommmandexecuted = dbg !DumpObj /d $section.Split(" ")[-2]
            $object = dbg !DumpObj /d $section.Split(" ")[-2]
            foreach($member in $object){
                if($member -like "String:*"){
                     $cleancommand = $member -split ':\s+',2
                     if(-not($aztokens)){ 
                        $finalCommandStructure += $cleancommand[1]
                     }
                     if($aztokens -and ($member -like "*eyJ*" -or $member -like "*eyJ*" -or $member -like "*graph*" -or $member -like "*Connect-AzAccount *" -or $member -like "*Get-Az*" -or $member -like "*az*" -or $member -like "" -or $member -like "*pscredential*")){
                        $finalCommandStructure += $cleancommand[1]
                     }
                        }
       }
}
    }
}
Disconnect-Dbgsession
$finalCommandStructure
