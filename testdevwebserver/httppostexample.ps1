@"
<html><head></head><body><ul>

$( 
    If($POSTDATA["text1"]) {
    "text1 = $($POSTDATA["text1"])"
    }
)

<form action="http://localhost:8080/httppostexample.ps1" method="POST" name="myform">
<input type="textfield" name="text1" />
<input type="submit">
</form>
</ul></body></html>
"@

