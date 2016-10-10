
function Handle-RequestForDirectory {

param(
    $generatedWinFilePath, 
    $requestURL
)

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

    if($found -eq $false) { #no index file found.. now resort to directory browsing..
        $content = [System.Text.Encoding]::UTF8.GetBytes(( _showDirectory $generatedWinFilePath $requestUrl))
        #write-host "[$requestIP] - $([datetime]::Now.ToString()) - $HTTPMethod - $requestUrl - $($response.StatusCode)"; 
    }

    return $content;
}

function _showDirectory {
param (
	$filepath, 
	[System.Uri]$requestUrlParam
)

  $parentURL = _generateParentFolderURL $requestUrlParam
   $htmlheader = "<html><head><title>Browsing - $Global:WebsiteURL</title></head><body>
   <h1>Browsing $requestUrlParam</h1><hr />
   <a href=""$parentURL"">[Parent Folder]</a><br/>
   <br/><table><tr><th>Mode</th><th>Last Modified</th><th>Name</th></tr>"
   $ul = ls $filepath | % {
        "<tr><td>$($_.Mode)</td><td>$($_.LastWriteTime)</td><td><a href=""$([string]::Concat($requestUrlParam,'/' ,$_.Name))"">$($_.Name)</a></td></tr>"

   }

   $htmlfooter = "</table></body></html>"
   return ($htmlheader + $ul +  $htmlfooter)
}

function _generateParentFolderURL {
param([string]$urlstring) 
    if($urlstring.EndsWith('/')){ 
        $urlstring = $urlstring.TrimEnd('/')
    } 
    [int]$index = $urlstring.LastIndexOf('/')
    return ($urlstring.Substring(0,$index))
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
 	'.css'    = 'text/css; charset=UTF-8';
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
 	'.htm'    = 'text/html; charset=UTF-8';
 	'.html'   = 'text/html; charset=UTF-8';
 	'.ief'    = 'image/ief';
 	'.jpe'    = 'image/jpeg';
 	'.jpeg'   = 'image/jpeg';
 	'.jpg'    = 'image/jpeg';
 	'.js'     = 'application/javascript; charset=UTF-8';
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
 	'.ps1'     = 'text/html; charset=UTF-8';
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
 	'.txt'    = 'text/plain; charset=UTF-8';
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