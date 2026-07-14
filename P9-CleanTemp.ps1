$temp = "$env:TEMP\*"
Remove-Item $temp -Force -Recurse -ErrorAction SilentlyContinue