<#
	Jenkins.ps1 is used to document the steps done by jenkins :

	1. Import the HTTPServer powershell module.
	2. cd C:\Users\steve\Documents\GitHub\Benevolent-HTTP-Server\testdevwebserver
	3. Start the webserver using the test folder 'testdevwebserver' (this has all the resources for testing, such as html, .js, .css and .png files)
	4. Invoke-Pester on the automated tests. integration tests may be slow so a delay on jenkins may need to be set to hourly, and the unit tests run every 15 mins.
	
	Note: invoke-pester can run a single .tests.ps1 file by passing the filepath as a parameter.
#>
Write-Output 'Hello Pester and Jenkins...'