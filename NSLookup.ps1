# This script reads a file called input.csv with column headers 'IP Address', 'Name' and 'DNS Domain'
#
# Each IP address in the IP Address column has NSLookup run against it.
#
# The host and domain names returned by NS Lookup are checked aagainst 
# the name in the Name column and the domain in the DNS Domain column.
#
# The matches are noted and the output sent to a CSV file called output.csv.
#
# Rows without IP addresses are noted rather than discarded
# 
# Using Write-Host for script progress is just for comfort
#


# Read the input CSV file
$inputFile = Import-Csv -Path "input.csv"

# Initialize a row counter
$rowCounter = 2

# Initialize an array to store the results
$results = @()

# Loop through each entry in the input CSV
foreach ($entry in $inputFile) {
    $ipAddress = $entry.'IP Address'
    $expectedName = $entry.'Name'
    $expectedDomain = $entry.'DNS Domain'

    # Check if IP Address is empty
    if ([string]::IsNullOrEmpty($ipAddress)) {
        Write-Host "Row $rowCounter Missing IP Address"
        $results += [PSCustomObject]@{
            'Row' = $rowCounter
            'IP Address' = $ipAddress
            'Expected Name' = $expectedName
            'Expected DNS Domain' = $expectedDomain
            'NameHost Returned by Nslookup' = "N/A"
            'Name Matched' = $false
            'Domain Matched' = $false
            'Status' = "Missing IP Address"
        }
        $rowCounter++
        continue
    }

    # Perform nslookup and capture the result
    $nslookupResult = Resolve-DnsName -Name $ipAddress

    # Extract the hostname and domains from the FQDN returned by nslookup
    # $actualName = $nslookupResult.NameHost.Split('.')[0]
    # $actualDomain = $nslookupResult.NameHost.Split('.')[1]
    $actualFQDN = $nslookupResult.NameHost
    $actualName = $actualFQDN.Split('.')[0]
    $actualDomain = ($actualFQDN -replace "^$actualName\.", "")

    # Check if the IP address responds to ping
    $pingResult = Test-Connection -ComputerName $ipAddress -Count 1 -ErrorAction SilentlyContinue
    $pingResponse = $pingResult -ne $null

    $nameMatched = $actualName -eq $expectedName
    $domainMatched = $actualDomain -eq $expectedDomain

    $results += [PSCustomObject]@{
        'Row' = $rowCounter
        'IP Address' = $ipAddress
        'Expected Name' = $expectedName
        'Expected DNS Domain' = $expectedDomain
        'NameHost Returned by Nslookup' = $nslookupResult.NameHost
        'Name Matched' = $nameMatched
        'Domain Matched' = $domainMatched
        'Ping Response' = $pingResponse
        'Status' = "OK"
    }

    Write-Host "Row $rowCounter"
    Write-Host "  IP Address: $ipAddress"
    Write-Host "  NameHost Returned by Nslookup: $($nslookupResult.NameHost)"
    Write-Host "  Actual Name: $actualName"
    Write-Host "  Expected Name: $expectedName"
    Write-Host "  Actual Domain: $actualDomain"
    Write-Host "  Expected Domain: $expectedDomain"
    Write-Host "  Name Matched: $nameMatched"
    Write-Host "  Domain Matched: $domainMatched"
    Write-Host "  Ping Response: $pingResponse"

    $rowCounter++
}

# Export the results to a new CSV file
$results | Export-Csv -Path "output.csv" -NoTypeInformation

Write-Host "Processing complete."
