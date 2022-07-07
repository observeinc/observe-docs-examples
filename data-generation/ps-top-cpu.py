#!/usr/bin/python3

# Sample data generating script for the Ingesting and Exploring Data with
# Observe tutorial
#
# This code is provided as-is for educational purposes. Not for production use

import subprocess
import time
import urllib.request

#####
# Update the following values:

# path and host are used to construct the collection URL
# Example:
# https://collect.observeinc.com/v1/http/<my_path>?host=<my_host>
my_path = "my-ps-top-cpu"
my_host = "my-observe-laptop"

# customer_id and ingest_token are sent in an Authorization header
customer_id = "101"
ingest_token = "my-token"

# The command to run: get the process using the most cpu
# Uncomment the appropriate one for your system
# MacOS:
# cmd = "ps -Ao pid,pcpu,comm -r -c | head -n 2 | sed 1d"
# Linux:
# cmd = "ps -eo pid,pcpu,comm --sort=-pcpu | head -n 2 | sed 1d"

# End required updates
#####

# Optional:
# How long to wait between samples, in seconds
sleep_time_sec = 10

# The Observe collection endpoint - do not change
observe_url = "https://collect.observeinc.com/v1/http"


# Main loop
while True:
    # Execute the command
    p = subprocess.Popen(cmd,
                         shell=True,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT)

    # Parse the first line of the output (the default cmd only emits one line)
    line = p.stdout.readline()
    pid, cpu, command = line.decode('utf-8').strip().split(maxsplit=2)

    # Construct the JSON payload
    str = '{{\"pid\":{}, \"cpu\":{}, \"command\":\"{}\"}}'
    payload = str.format(pid, cpu, command)

    # Construct the request
    req = urllib.request.Request(
        url=(observe_url + '/' + my_path + '?' + "host=" + my_host),
        method="POST",
        data=bytes(payload.encode("utf-8")))

    req.add_header("Authorization",
                   "Bearer " + customer_id + " " + ingest_token)
    req.add_header("Content-type", "application/json")

    # Send the request
    response = urllib.request.urlopen(req)
    json_response = response.read().decode("utf-8")

    # Print the output for debugging
    print("request:   " + payload)
    print("response:  " + json_response)

    # Wait before getting the next sample
    time.sleep(sleep_time_sec)
