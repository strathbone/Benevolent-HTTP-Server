[string]$script:_url = "http://localhost:8080/";
[bool]$script:_directoryBrowsing = $true;
[string]$script:_documentRoot = "";
[System.Net.HttpListener]$script:_listener = $null;
$script:POST;

$script:routes = @{
    "/ola" = { return "<html><body>Hello world!</body></html>" }
}

function Start-WebServer {
param(
    [string]$folder = $(get-location),
    [string]$urlParam = "http://localhost:8080/"
) 
    $script:_documentRoot = $folder;
    $script:_url = $urlParam;
    $script:_listener = New-Object System.Net.HttpListener;
    $script:_listener.Prefixes.Add($script:_url);
    $script:_listener.Start();
 
    Write-Host "Listening at $script:_url...";
    #TODO: create event type
    
    while ( $script:_listener.IsListening ) { _handleHTTPRequest }
}

function Stop-WebServer {
    return "stopping...";
}

function Restart-WebServer {
    return "restarting...";
}

function  Get-StaticFileContent {
param ($path, $extension)
    return Get-Content $path;

}

function _handleHTTPRequest {
    #TODO: invoke event
    [System.Net.HttpListenerContext]$context = $script:_listener.GetContext();
    [System.Net.HttpListenerResponse]$response = $context.Response;
    [System.Uri]$requestUrl = $context.Request.Url;
    $requestIP = $context.Request.UserHostAddress;
    $HTTPMethod = $context.Request.HttpMethod;
    [string]$generatedWinFilePath = $null;
    
   
   if($HTTPMethod -eq "POST") {
        Add-Type -AssemblyName "System.Web"
        $httputil = New-Object System.Web.HttpUtility; 
        # Having HttpListenerContext in context
        $body = $context.Request.InputStream;
        Write-Host $body.GetType()
        $encoding = $context.Request.ContentEncoding
        $sr = New-Object System.IO.StreamReader($body)
        $POSTDATA = [System.Web.HttpUtility]::ParseQueryString($sr.ReadToEnd(), $encoding)
    }
  
  
  
    $generatedWinFilePath = _createWindowsFilePathFromURL $requestUrl  
     
    # Write-Host $context.Request.UserHostAddress
    #check if file exists...
    #if yes, get it's file extension and return it with the mimetype
    #if not, look in the routes table... 
    $content = "";
    if( Test-Path $generatedWinFilePath) 
    {
        $fileOrDirTest = _isPathFileOrFolder $generatedWinFilePath;
        
        if($fileOrDirTest  -eq "directory" ) 
        {
            $files = @('index.html','index.htm');
            $found = $false;

            foreach ($file in $files) { #directory found - looking for a index.html file...
                if(Test-Path "$generatedWinFilePath\$file") { 
                    $found = $true;
                    [string]$fileExtension = [System.IO.Path]::GetExtension( "$generatedWinFilePath\$file");
                    $content = [System.IO.File]::ReadAllBytes( "$generatedWinFilePath\$file");
                    break;
                } 
            }

            if($found -eq $false) { #no index file found.. now resort to directory browsing then return early.
                $content = [System.Text.Encoding]::UTF8.GetBytes((_showDirectory $generatedWinFilePath $requestUrl))
                $response.StatusCode = 200;
                $response.ContentType = 'text/html';
                $response.ContentLength64 = $content.Length;
                $response.OutputStream.Write($content, 0, $content.Length);
                $response.Close();
 
                write-host "[$requestIP] - $([datetime]::Now.ToString()) - $HTTPMethod - $requestUrl - $($response.StatusCode)"; 
                return;
            }
        }
        if($fileOrDirTest -eq "file" ) { #the url matches a physical file on the HDD in the current folder...
           
            [string]$fileExtension = [System.IO.Path]::GetExtension( $generatedWinFilePath)
          
            if($fileExtension -ne '.ps1') {
                $content = [System.IO.File]::ReadAllBytes( $generatedWinFilePath);  
            }
            else {
               $content = [System.Text.Encoding]::UTF8.GetBytes( (. $generatedWinFilePath));     
            }
        }
           
        $buffer = $content
        $response.StatusCode = 200;
        $response.ContentType = _guessMimeType $fileExtension;
        $response.ContentLength64 = $buffer.Length;
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

function _getDefaultDocument {
    param($path)
    $files = @('index.html','index.htm')

    foreach ($file in $files) {
       if(Test-Path "$path\$file") {return Get-Content -Path "$path\$file"}
       else{return -1}
    }
}

function _createWindowsFilePathFromURL {
param(
    [System.Uri]$URLParam
)
    [string]$generatedPath = "";
    [string]$localPath = $URLParam.LocalPath;
   
    $generatedPath = ([string]::Concat( $script:_documentRoot, $localPath.Replace('/','\') ));
    
    return $generatedPath;
}

function _isPathFileOrFolder( [string]$filePathParam ) {
    # http://stackoverflow.com/questions/1395205/better-way-to-check-if-path-is-a-file-or-a-directory
    # get the file attributes for file or directory
    [System.IO.FileAttributes]$attr = [System.IO.File]::GetAttributes($filePathParam);
    
    #detect whether its a directory or file
    if (($attr -band [System.IO.FileAttributes]::Directory) -eq [System.IO.FileAttributes]::Directory) {
        return "directory";
    }
    else {
        return "file";
    }
}

function _showDirectory {
param ($filepath, $url)
   $htmlheader = "<html><head></head><body><ul>"
   $ul = ls $filepath | % {
        "<li><a href=""$([string]::Concat($url, "/", $_.Name))"">$($_.Name)</a></li>"

   }

   $htmlfooter = "</ul></body></html>"
   return ($htmlheader + $ul +  $htmlfooter)
}

function _guessMimeType {
param([string]$fileExt)
    $mimetypes = @{
 	'.a'      = 'application/octet-stream';
 	'.ai'     = 'application/postscript';
 	'.aif'    = 'audio/x-aiff';
 	'.aifc'   = 'audio/x-aiff';
 	'.aiff'   = 'audio/x-aiff';
 	'.au'     = 'audio/basic';
 	'.avi'    = 'video/x-msvideo';
 	'.bat'    = 'text/plain';
 	'.bcpio'  = 'application/x-bcpio';
 	'.bin'    = 'application/octet-stream';
 	'.bmp'    = 'image/x-ms-bmp';
 	'.c'      = 'text/plain';
 	'.cdf'    = 'application/x-cdf';
 	'.cpio'   = 'application/x-cpio';
 	'.csh'    = 'application/x-csh';
 	'.css'    = 'text/css';
 	'.dll'    = 'application/octet-stream';
 	'.doc'    = 'application/msword';
 	'.dot'    = 'application/msword';
 	'.dvi'    = 'application/x-dvi';
 	'.eml'    = 'message/rfc822';
 	'.eps'    = 'application/postscript';
 	'.etx'    = 'text/x-setext';
 	'.exe'    = 'application/octet-stream';
 	'.gif'    = 'image/gif';
 	'.gtar'   = 'application/x-gtar';
 	'.h'      = 'text/plain';
 	'.hdf'    = 'application/x-hdf';
 	'.htm'    = 'text/html';
 	'.html'   = 'text/html';
 	'.ief'    = 'image/ief';
 	'.jpe'    = 'image/jpeg';
 	'.jpeg'   = 'image/jpeg';
 	'.jpg'    = 'image/jpeg';
 	'.js'     = 'application/javascript';
 	'.ksh'    = 'text/plain';
 	'.latex'  = 'application/x-latex';
 	'.m1v'    = 'video/mpeg';
 	'.man'    = 'application/x-troff-man';
 	'.me'     = 'application/x-troff-me';
 	'.mht'    = 'message/rfc822';
 	'.mhtml'  = 'message/rfc822';
 	'.mif'    = 'application/x-mif';
 	'.mov'    = 'video/quicktime';
 	'.movie'  = 'video/x-sgi-movie';
 	'.mp2'    = 'audio/mpeg';
 	'.mp3'    = 'audio/mpeg';
 	'.mp4'    = 'video/mp4';
 	'.mpa'    = 'video/mpeg';
 	'.mpe'    = 'video/mpeg';
 	'.mpeg'   = 'video/mpeg';
 	'.mpg'    = 'video/mpeg';
 	'.ms'     = 'application/x-troff-ms';
 	'.nc'     = 'application/x-netcdf';
 	'.nws'    = 'message/rfc822';
 	'.o'      = 'application/octet-stream';
 	'.obj'    = 'application/octet-stream';
 	'.oda'    = 'application/oda';
 	'.p12'    = 'application/x-pkcs12';
 	'.p7c'    = 'application/pkcs7-mime';
 	'.pbm'    = 'image/x-portable-bitmap';
 	'.pdf'    = 'application/pdf';
 	'.pfx'    = 'application/x-pkcs12';
 	'.pgm'    = 'image/x-portable-graymap';
 	'.pl'     = 'text/plain';
 	'.png'    = 'image/png';
 	'.pnm'    = 'image/x-portable-anymap';
 	'.pot'    = 'application/vnd.ms-powerpoint';
 	'.ppa'    = 'application/vnd.ms-powerpoint';
 	'.ppm'    = 'image/x-portable-pixmap';
 	'.pps'    = 'application/vnd.ms-powerpoint';
 	'.ppt'    = 'application/vnd.ms-powerpoint';
 	'.ps'     = 'application/postscript';
 	'.ps1'     = 'text/html';
 	'.pwz'    = 'application/vnd.ms-powerpoint';
 	'.py'     = 'text/x-python';
 	'.pyc'    = 'application/x-python-code';
 	'.pyo'    = 'application/x-python-code';
 	'.qt'     = 'video/quicktime';
 	'.ra'     = 'audio/x-pn-realaudio';
 	'.ram'    = 'application/x-pn-realaudio';
 	'.ras'    = 'image/x-cmu-raster';
 	'.rdf'    = 'application/xml';
 	'.rgb'    = 'image/x-rgb';
 	'.roff'   = 'application/x-troff';
 	'.rtx'    = 'text/richtext';
 	'.sgm'    = 'text/x-sgml';
 	'.sgml'   = 'text/x-sgml';
 	'.sh'     = 'application/x-sh';
 	'.shar'   = 'application/x-shar';
 	'.snd'    = 'audio/basic';
 	'.so'     = 'application/octet-stream';
 	'.src'    = 'application/x-wais-source';
 	'.sv4cpio'= 'application/x-sv4cpio';
 	'.sv4crc' = 'application/x-sv4crc';
 	'.swf'    = 'application/x-shockwave-flash';
 	'.t'      = 'application/x-troff';
 	'.tar'    = 'application/x-tar';
 	'.tcl'    = 'application/x-tcl';
 	'.tex'    = 'application/x-tex';
 	'.texi'   = 'application/x-texinfo';
 	'.texinfo'= 'application/x-texinfo';
 	'.tif'    = 'image/tiff';
 	'.tiff'   = 'image/tiff';
 	'.tr'     = 'application/x-troff';
 	'.tsv'    = 'text/tab-separated-values';
 	'.txt'    = 'text/plain';
 	'.ustar'  = 'application/x-ustar';
 	'.vcf'    = 'text/x-vcard';
 	'.wav'    = 'audio/x-wav';
 	'.wiz'    = 'application/msword';
 	'.wsdl'   = 'application/xml';
 	'.xbm'    = 'image/x-xbitmap';
 	'.xlb'    = 'application/vnd.ms-excel';
 	'.xls'    = 'application/excel';
 	'.xml'    = 'text/xml';
 	'.xpdl'   = 'application/xml';
 	'.xpm'    = 'image/x-xpixmap';
 	'.xsl'    = 'application/xml';
 	'.xwd'    = 'image/x-xwindowdump';
 	'.zip'    = 'application/zip';
    }
    return $mimetypes[$fileExt];
}