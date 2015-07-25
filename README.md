# Benevolent-HTTP-Server
Benevolent HTTP Server: A simple web server that can be run from the shell, or embedded in ISE as an add-on.

## Features:
- Can be started from any directory in within powershell console, just type 'Start-WebServer' and it's ready to go.
- Accepts URL binding as a parameter - uses localhost:9000 as default.
- Process HTML forms using HTTP POST.
- Detects a large list of known MIME types based on file extension, including images, css, javascript, pdf.
- Interperets '.ps1' files as serverside scripts, returning the output to the browser.
- Directory browsing.
- Utilizes Http.sys, but is otherwise written as a Powershell module. (No C# or DLL's required!).
- Can be added into ISE easily, creating new workflow possiblilities - Manage the webserver from the ISE Menu, and open .ps1 files directly into your browser of choice.
