@"
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Processes for $($env:COMPUTERNAME)</title>
</head>

<body>
<h2>Processes for $($env:COMPUTERNAME)</h2>
<br/>
 $(
	Get-Process | select Name, Handles, VM, WS, PM, NPM, Path, Company, CPU | ConvertTo-Html -Fragment	
  )

</body>
</html> 
"@