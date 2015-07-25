# Benevolent-HTTP-Server
Benevolent HTTP Server: A simple web server that can be run from the shell, or embedded in ISE as an add-on.

## Features:
- Can be started from any directory in within powershell console, just type 'Start-WebServer' and it's ready to go.
- Accepts URL binding as a parameter - uses localhost:9000 as default.
- Processes HTML forms using HTTP POST.
- Directory browsing.
- Detects a large list of known MIME types based on file extension, such as image files, css, javascript and pdf.
- Interperets '.ps1' files as server side scripts, returning the output to the browser.
- Utilizes Http.sys, but is otherwise written as a Powershell module. (No C# or DLL's required!)
- Can be added into ISE easily, creating new workflow possiblilities. Manage the webserver directly in ISE, and open .ps1 files into your browser of choice by using the menu.
