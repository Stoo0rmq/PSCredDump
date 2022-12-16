# PSCredDump
Very simple PS script that allows you to parse interesting things from a powershell.exe dump process. 

Today I needed to extract Azure related stuff from a Powershell.exe dump file and ended on this nice blog post (https://www.leeholmes.com/extracting-activity-history-from-powershell-process-dumps/). As a result I decided to put it on a PowerShell script to make it easy to grab all the access tokens as well as Azure related credentials.

- Step 1 : Do a dump of a Powershell.exe process
- Step 2: run the script .\PSCredDump.ps1 -dump C:\Users\user\Desktop\DUMP.DMP -aztokens
- Step 3: wait some seconds (yes, WinDBG is a bit slow)
- Step 4: profit!


NOTE: if you dont use the -aztokens flag it will try to return you a list of commands executed that might be interesting
