Describe "HTTP WebServer" {
	cd TestDrive:\;
	$currFolder = $testDrive;
	$bindingAddress = 'http://localhost:8080/';

	$job = start-job -Name 'Webserver' -ScriptBlock { 
	param($folder, $address)
		import-module .\HTTPServer;
		start-webserver $folder $address;
	} -ArgumentList @($testDrive, $bindingAddress)

	Start-Sleep -Seconds 1;

	It "invokes a web request to $bindingAddress, content greater than 30 chars" {
		$response = Invoke-WebRequest -Uri $bindingAddress;
		$response.Content.Length  | Should BeGreaterThan 30;
	}

	It "invokes a web request to $bindingAddress, HTTP statuscode equal to 200" {
		$response = Invoke-WebRequest -Uri $bindingAddress;
		$response.StatusCode  | Should BeExactly 200;
	}

	It "invokes a web request to $bindingAddress, Directory browsing working" {

		if( Test-Path -Path 'index.html') {
			Remove-Item -Path 'index.html';
		}

		if( Test-Path -Path 'index.htm') {
			Remove-Item -Path 'index.htm';
		}
		
		$response = Invoke-WebRequest -Uri $bindingAddress;
		$titletext = $response.ParsedHTML.getElementsByTagName("title") | select text;
		$titletext.text | Should BeExactly "Browsing - $bindingAddress";
	}

	It "invokes a web request to $($bindingAddress+'index.html'), returning index.html explicitly" {
		New-item 'index.html' -Type file;
		Add-Content -Path 'index.html' -Value '<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>hello</h1></body></html>';
		$requestURL =  ([string]::Concat( $bindingAddress,'index.html'));
		$response = Invoke-WebRequest -Uri $requestURL;
		$response.content | Should match '<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>hello</h1></body></html>';
		Remove-Item -Path 'index.html'
	}

	It "invokes a web request to $($bindingAddress+'index.htm'), returning index.htm explicitly" {
		New-item 'index.htm' -Type file;
		Add-Content -Path 'index.htm' -Value '<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>hello htm</h1></body></html>';
		$requestURL = ([string]::Concat( $bindingAddress,'index.htm'));
		$response = Invoke-WebRequest -Uri $requestURL;
		$response.content | Should match '<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>hello htm</h1></body></html>';
		Remove-Item -Path 'index.htm'
	}

	It "invokes a web request to $bindingAddress, returning index.html implcitly" {
		New-item 'index.html' -Type file;
		Add-Content -Path 'index.html' -Value '<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>implict</h1></body></html>';
		$response = Invoke-WebRequest -Uri $bindingAddress;
		$response.content | Should match '<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>implict</h1></body></html>';
		Remove-Item -Path 'index.html'
	}

	It "invokes a web request to $bindingAddress, returning index.htm implcitly" {
		New-item 'index.htm' -Type file;
		Add-Content -Path 'index.htm' -Value '<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>implict htm</h1></body></html>';
		$response = Invoke-WebRequest -Uri $bindingAddress;
		$response.content | Should match '<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>implict htm</h1></body></html>';
		Remove-Item -Path 'index.htm'
	}

	It "invokes a web request to $bindingAddress, returning index.html implcitly when both index.html and index.htm exist in the same folder" {
		New-item 'index.html' -Type file;
		Add-Content -Path 'index.html' -Value '<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>index.html</h1></body></html>';
		New-item 'index.htm' -Type file;
		Add-Content -Path 'index.htm' -Value '<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>index.htm</h1></body></html>';
		
		$response = Invoke-WebRequest -Uri $bindingAddress;
		$response.content | Should match '<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>index.html</h1></body></html>';
		Remove-Item -Path 'index.html'
		Remove-Item -Path 'index.htm'
	}

	It "invokes a web request to $bindingAddress, returning index.html implcitly and checking that the content type is text/html and charset is UTF-8" {
		New-item 'index.html' -Type file;
		Add-Content -Path 'index.html' -Value '<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>index.html</h1></body></html>';
		$response = Invoke-WebRequest -Uri $bindingAddress;
		$response.Headers['Content-Type'] | Should match 'text/html; charset=UTF-8';
		Remove-Item -Path 'index.html'
	}
	
	It "starts webserver using a invalid URL binding." {
		$false | Should Be $true
	}

	It "starts webserver using non admin account." {
		$false | Should Be $true
	}

	It "starts webserver using 32 bit mode" {
		$false | Should Be $true
	}

	It "starts webserver using 64 bit mode" {
		$false | Should Be $true
	}

	It "starts webserver using STA mode" {
		$false | Should Be $true
	}

	It "starts webserver using MTA mode" {
		$false | Should Be $true
	}

	It "requests html file that is in another encoding. (file is latin encoding, convert to utf-8." {
		$text = 'The cat sat on the mat.'
		$filePath = $testDrive+"index.html"
		
		[System.IO.File]::WriteAllText($filePath,$text,[System.Text.Encoding]::GetEncoding('iso-8859-1'))
		
		$response = Invoke-WebRequest -Uri $bindingAddress;
		$response.content | Should match 'The cat sat on the mat.'
		
	}
	
	It "requests html file that is locked. (system is using it for another process)" {
		
		#to create this test just open a file up in notepad++ while running the tests...
		$false | Should Be $true
	}

	It "requests html file that is hidden. should return a 404" {
			New-item 'index.html' -Type file;
		Add-Content -Path 'index.html' -Value '<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>implict</h1></body></html>';
		$file = Get-ChildItem 'index.html'
        $file.Attributes = "hidden"
        $response = Invoke-WebRequest -Uri $bindingAddress;
		$response.content | Should match '<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body><h1>implict</h1></body></html>';
		Remove-Item -Path 'index.html'
	}

	It "requests html file that has no NTFS read permissions - should return 401" {
		$false | Should Be $true
	}
	
	It "requests html file with extra `/ at the end of the URL. should redirect request w/o extra slash." {
		$false | Should Be $true
	}

	It "request an index.html file in a subfolder" {
		$false | Should Be $true
	}

	It "request an index.htm file from a subfolder" {
		$false | Should Be $true
	}

	It "request an image file from a subfolder" {
		$false | Should Be $true
	}
		It "request a .js file from a subfolder" {
		$false | Should Be $true
	}

	It "request a POST request with a form that uses a radio button" {
		$false | Should Be $true
	}
	
	It "request a POST request with a form that uses a checkbox" {
		$false | Should Be $true
	}

	It "request a POST request with a form that uses a textbox" {
		$false | Should Be $true
	}

	It "request a POST request with a form that uses a textarea" {
		$false | Should Be $true
	}

	It "request a POST request with a form that uses a select" {
		$false | Should Be $true
	}

	It "request a POST request with a form that uses a option" {
		$false | Should Be $true
	}

	cd $PSScriptRoot;
	Stop-Job $job.Id;
	Write-Host 'GOODBYE';
}