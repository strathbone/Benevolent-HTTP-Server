function Get-PostData  {
	param(
		[System.Net.HttpListenerContext]
		$httpContext
	)
	
	Add-Type -AssemblyName 'System.Web'
    $httputil = New-Object System.Web.HttpUtility; 
    # Having HttpListenerContext in context
    $body = $httpContext.Request.InputStream;
    $encoding = $httpContext.Request.ContentEncoding
    $sr = New-Object System.IO.StreamReader($body)
    return [System.Web.HttpUtility]::ParseQueryString($sr.ReadToEnd(), $encoding)
}


function TestFilePath ([string]$path) {
    $result = $false;

    if(Test-Path $path) {
        $o = Get-ChildItem $path 
        if (($o.Attributes.ToString() -Split ", ") -Contains "Hidden"){
            $result = $false;
        } else {
            $result = $true;
        }
    } else {
        $result = $false;
    }
    return $result
}