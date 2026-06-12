#Requires -Version 5.1
Get-Process | Where-Object { $_.MainWindowTitle -match 'ドールズ|Dolls|FRONTLINE|少女' } |
    Select-Object ProcessName, Id, MainWindowTitle | Format-Table -AutoSize
