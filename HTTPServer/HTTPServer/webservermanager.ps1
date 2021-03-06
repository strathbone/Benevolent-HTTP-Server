﻿$currFolder = Get-Location
Write-Output "current folder is $currFolder"
$bindingAddress = 'http://localhost:8000/'

start-job -Name 'Webserver' -ScriptBlock { 
param($folder, $address)
  cd $currFolder
    import-module .\HTTPServer
    start-webserver $folder.Path $address
 } -ArgumentList @($currFolder, $bindingAddress)