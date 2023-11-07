# NSLookup-And-Ping

# A script to confirm the DNS configuration and PING response of a list of servers.

This script reads a file called input.csv with column headers 'IP Address', 'Name' and 'DNS Domain'

Each IP address in the IP Address column has NSLookup run against it.

The host and domain names returned by NS Lookup are checked aagainst the name in the Name column and the domain in the DNS Domain column.

The matches are noted and the output sent to a CSV file called output.csv.

Rows without IP addresses are noted rather than discarded

Using Write-Host for script progress is just for comfort
