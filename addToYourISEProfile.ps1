

$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add(
   "Start Web Server", { 
   . C:\HTTPServer\webservermanager.ps1
    },$null)

$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add(
   "Stop Web Server", { 
   stop-job Webserver
    },$null)

$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add(
    "Open in Firefox", { 
    Write-Output $psISE.CurrentFile.FullPath

   if( $psISE.CurrentFile.FullPath.StartsWith($currFolder.Path)) {
       $folderWithSlash = [string]::Concat($currFolder, '\');
    $gettingthere = $psISE.CurrentFile.FullPath.Replace($folderWithSlash, $bindingAddress)
    Write-Output $gettingthere
    Write-Output "reverse slashes"
    .'\Program Files (x86)\Mozilla Firefox\firefox.exe' $gettingthere

   }
},$null)

$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add(
    "Open in Chrome", { 
    Write-Output $psISE.CurrentFile.FullPath

   if( $psISE.CurrentFile.FullPath.StartsWith($currFolder.Path)) {
       $folderWithSlash = [string]::Concat($currFolder, '\');
    $gettingthere = $psISE.CurrentFile.FullPath.Replace($folderWithSlash, $bindingAddress)
    Write-Output $gettingthere
    Write-Output "reverse slashes"
    .'C:\Users\rathbone\AppData\Local\Google\Chrome\Application\chrome.exe' $gettingthere

   }
},$null)

$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add(
    "Open in Internet Explorer", { 
    Write-Output $psISE.CurrentFile.FullPath

   if( $psISE.CurrentFile.FullPath.StartsWith($currFolder.Path)) {
       $folderWithSlash = [string]::Concat($currFolder, '\');
    $gettingthere = $psISE.CurrentFile.FullPath.Replace($folderWithSlash, $bindingAddress)
    Write-Output $gettingthere
    Write-Output "reverse slashes"
    .'C:\Program Files\Internet Explorer\iexplore.exe' $gettingthere

   }
},$null)


$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("ClearMenu", 
   { $psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Clear() }, $null)