Set-StrictMode -Version 2.0

. $PSScriptRoot\functions.ps1
Import-Module $PSScriptRoot\StaticFileHandler.psm1

[string]$Global:WebsiteURL = 'http://localhost:8080';

[bool]$script:_directoryBrowsing = $true;
[string]$script:_documentRoot = '';
[System.Net.HttpListener]$script:_listener = $null;
$script:POST;

<#.Synopsis
Start the Webserver. The Folder path is optional so potentially this can be used alongside another editor without screwing up your workflow too much.
.DESCRIPTION

.EXAMPLE
Start-Webserver -folder c:\YourWebSite -urlParam 'http://localhost:8080/'

.EXAMPLE
Start-Webserver -urlParam 'http://localhost:9000/'

Start the webserver, but in the current location only (ie. the folder path that you normally see at the prompt). This is also the same as: Start-Webserver -folder (Get-Location).Path -urlParam 'http://localhost:9000/'. 
#>
function Start-WebServer {
param(
	[Parameter(Position=0, Mandatory=$false)]
	# Folder is optional. if you omit this paramter the web server will listen to current working directory
    [string] $folder = $(get-location),
	[Parameter(Position=1, Mandatory=$false)]
	# $urlParam This is the URL of the website. you'll need to specify the port number as well unfortunately. The format needs to be something like 'http://localhost:8080/'
    [string] $urlParam = 'http://localhost:8080/'
) 
    $script:_documentRoot = $folder;
    $Global:WebsiteURL = $urlParam;
    $script:_listener = New-Object System.Net.HttpListener;
    try {
		$script:_listener.Prefixes.Add($Global:WebsiteURL);
	}
	catch {
		return $_.exception;
	}
    $script:_listener.Start();
 
    Write-Host "Listening at $Global:WebsiteURL...";
    #TODO: create event type
    
    while ( $script:_listener.IsListening ) { _handleHTTPRequest }
}

<#.Synopsis
Stop the Webserver.
.DESCRIPTION
function is not written.
.EXAMPLE
Stop-Webserver -urlParam 'http://localhost:8080/'
#>
function Stop-WebServer {
    throw [NotImplementedException];
}

<#.Synopsis
Restart the Webserver.
.DESCRIPTION
function is not written.
.EXAMPLE

#>
function Restart-WebServer {
    throw [NotImplementedException];
}

<#.Synopsis
Stop the Webserver.
.DESCRIPTION
function is not written.
.EXAMPLE
Stop-Webserver -urlParam 'http://localhost:8080/'#>
function  Get-StaticFileContent {
param ($path, $extension)
    return Get-Content $path;

}

<#.Synopsis

.DESCRIPTION
Handle the HTTP request by retrieving the data from the HttpListenerContext object and writing the response to the context's HttpListenerResponse property.

This function will see if the requested file exists within the current folder, if it does it will then look at the file extension to determine the MIME type.
if the there is no file that exists with the given name in the folder, it will then look through the route table.

Also, if the web request has HTTP POST data attached, this will be extracted and available in the $POSTDATA variable.
.EXAMPLE#>
function _handleHTTPRequest {

    [System.Net.HttpListenerContext]$context = $script:_listener.GetContext();
    [System.Net.HttpListenerResponse]$response = $context.Response;
    [System.Uri]$requestUrl = $context.Request.Url;
    $requestIP = $context.Request.UserHostAddress;
    $HTTPMethod = $context.Request.HttpMethod;
    [string]$generatedWinFilePath = $null;
    
   if($HTTPMethod -eq 'POST') { $POSTDATA = Get-PostData $context}
  
    $generatedWinFilePath = _createWindowsFilePathFromURL $requestUrl  
     
    # Write-Host $context.Request.UserHostAddress
    #check if file exists...
    #if yes, get it's file extension and return it with the mimetype
    #if not, look in the routes table... 
    $content = "";
	$ContentType = 'text/html; charset=UTF-8'
    if( Test-Path $generatedWinFilePath) 
    {
        $fileOrDirTest = _isPathFileOrFolder $generatedWinFilePath;
        
        if($fileOrDirTest  -eq 'directory') 
        {
            $content = Handle-RequestForDirectory $generatedWinFilePath $requestUrl
        }
        if($fileOrDirTest -eq 'file' ) { #the url matches a physical file on the HDD in the current folder...
           
            [string]$fileExtension = [System.IO.Path]::GetExtension( $generatedWinFilePath)
          
            if($fileExtension -ne '.ps1') {
                $content = [System.IO.File]::ReadAllBytes( $generatedWinFilePath);  
                $ContentType = _guessMimeType $fileExtension;
            }
            else {
               $content = [System.Text.Encoding]::UTF8.GetBytes( (. $generatedWinFilePath));     
            }
        }
           
        $buffer = $content
        $response.StatusCode = 200;
        $response.ContentType = $ContentType
        $response.ContentLength64 = $buffer.Length

        $response.OutputStream.Write($buffer, 0, $buffer.Length);
        $response.Close();
 
        write-host "[$requestIP] - $([datetime]::Now.ToString()) - $HTTPMethod - $requestUrl - $($response.StatusCode)"; 
    }
    else {
       $route = $routes.Get_Item($requestUrl.LocalPath)
 
        if ($route -eq $null)
        {
            $response.StatusCode = 404;
        }
        else
        {
            $content = & $route
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($content);
            $response.ContentLength64 = $buffer.Length;
            $response.OutputStream.Write($buffer, 0, $buffer.Length);
            $response.StatusCode = 200;
        }
    
        $response.Close()
        write-host "[$requestIP] - $([datetime]::Now.ToString()) - $HTTPMethod - $requestUrl - $($response.StatusCode)"; 
    }
    
}

<#.Synopsis
Translates URL's to absolute file paths so that MS Windows can read the file contents.
.DESCRIPTION
Function will extract the requested filename (from the URL), and convert it to a Windows path by reversing the '/' to '\', and prefixing the full folder path where the webserver is listening.

So, if the URL requested is http://localhost:8080/index.html, we need to extract '/index.html', then join it to the path of where the webserver is listening. eg. 'C:\PowerShellProjects\yourwebsite\index.html'
The function also needs to be able to deal with nested paths like 'http://localhost:8080/images/header.png'

.EXAMPLE#>
function _createWindowsFilePathFromURL {
param(
	# convert 
    [System.Uri]$URLParam
)
    [string]$generatedPath = "";
    [string]$localPath = $URLParam.LocalPath;
   
    $generatedPath = ([string]::Concat( $script:_documentRoot, $localPath.Replace('/','\') ));
    
    return $generatedPath;
}

<#.Synopsis
A simple check to determine if the given path is a folder or file.
.DESCRIPTION
Function is used for when Folder Browsing enabled, so that either a list of files and subfolders are returned to the user, or if it's a file, the actial file contents.
This function also needs to make sure that the folder name doesn't have any '.' in the name.
.EXAMPLE#>
function _isPathFileOrFolder {
     param
     (
         [string]
         $filePathParam
     )

    # http://stackoverflow.com/questions/1395205/better-way-to-check-if-path-is-a-file-or-a-directory
    # get the file attributes for file or directory
    [System.IO.FileAttributes]$attr = [System.IO.File]::GetAttributes($filePathParam);
    
    #detect whether its a directory or file
    if (($attr -band [System.IO.FileAttributes]::Directory) -eq [System.IO.FileAttributes]::Directory) {
        return 'directory';
    }
    else {
        return 'file';
    }
}

$script:routes = @{
    '/Home' = { return '<html><body>Hello world!</body></html>' }
}