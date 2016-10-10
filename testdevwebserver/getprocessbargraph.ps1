$resultdata = Get-Process | Sort-Object -Property PM -Descending |select -First 20 -Property Name, PM

$processNames = $resultdata | %{$_.Name} | ConvertTo-Json
$processVMUsage = $resultdata | %{$_.PM /1MB} | ConvertTo-Json

@"
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Processes for $($env:COMPUTERNAME)</title>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/1.0.2/Chart.js"></script>

</head>

<body>
<h2>Processes for $($env:COMPUTERNAME)</h2>
<canvas id="myChart" width="600" height="400"></canvas>
<script>

var data = {
    labels: $processNames,
    datasets: [
        {
            label: "My First dataset",
            fillColor: "rgba(220,220,220,0.5)",
            strokeColor: "rgba(220,220,220,0.8)",
            highlightFill: "rgba(220,220,220,0.75)",
            highlightStroke: "rgba(220,220,220,1)",
            data: $processVMUsage
        }
    ]
};

var ctx = document.getElementById("myChart").getContext("2d");
var myBarChart = new Chart(ctx).Bar(data, null);

</script>
</body>
</html> 
"@