# Sample data generating script for the 
# Ingesting and Exploring Data with Observe tutorial
#
# This code is provided as-is for educational purposes.
# Not for production use.
# Tested with PowerShell on Windows 10 Pro

#####
# Update the following values:

# path and host are used to construct the collection URL
# Example:
# https://collect.observeinc.com/v1/observations/my_path?host=my-laptop
$path = "my-ps-top-cpu"
$win_host = "my-win10"

# customer_id and ingest_token are sent in an Authorization header
$ingest_token = "12345"
$customer_id = "123"

# End required updates
#####

# Optional:
# How long to wait between samples, in seconds
$sleep_time = 10

# The Observe collection endpoint - do not change
$observe_url = "https://collect.observeinc.com/v1/observations"


$auth_header = "Bearer " + $customer_id + " " + $ingest_token
$header = @{
 "Authorization"= $auth_header
 "Content-Type"="application/json"
}

# Construct the full URL
$uri = $observe_url + "/" + $path + "?host=" + $win_host

# get details of the process using the most cpu
Function Get-CPUProcess
{
$properties=@(
    @{Name="Name"; Expression = {$_.name}},
    @{Name="PID"; Expression = {$_.IDProcess}},
    @{Name="CPU (%)"; Expression = {$_.PercentProcessorTime}}
)
$ProcessCPU = Get-WmiObject -class Win32_PerfFormattedData_PerfProc_Process |
    Select-Object $properties |
    Where-Object {$_.name -ne 'Idle'} |
    Where-Object {$_.name -ne '_Total'} |
    Sort-Object "CPU (%)" -desc |
    Select-Object -First 1
    $ProcessCPU
}

# main loop
while($true) {
    # Get the top cpu using process
    $output = Get-CPUProcess

    # Extract the values of interest
    $win_command = $output.Name
    $win_pid = $output.PID
    $win_cpu = $output."CPU (%)"

    # Construct the payload
    $body = @{
        "pid" = $win_pid
        "cpu" = $win_cpu
        "command" = $win_command
    } | ConvertTo-Json

    # Send this observation to Observe
    Invoke-RestMethod -Uri $uri -Method 'Post' -Body $body -Headers $header | ConvertTo-HTML

    # Wait before next sample
    Start-Sleep -s $sleep_time
}