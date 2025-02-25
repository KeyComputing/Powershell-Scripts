# Run the WMIC command and get results
$services = wmic service get Name,PathName,DisplayName,StartMode | findstr /i auto | findstr /i /v "C:\Windows\\" | findstr /i /v "\"""

foreach ($line in $services) {
    # Splitting based on excessive spaces
    $parts = $line -split '\s{2,}'

    if ($parts.Count -ge 2) {
        $serviceName = $parts[0]
        $imagePath = $parts[1].Trim()

        # Ensure the path is unquoted and contains spaces
        if ($imagePath -match "\s" -and $imagePath -notmatch '^".*"$') {
            Write-Output ("Fixing unquoted path for service: " + $serviceName)

            # Add quotes around the path
            $quotedPath = '"' + $imagePath + '"'

            # Update the registry with the corrected path
            $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$serviceName"
            Set-ItemProperty -Path $registryPath -Name ImagePath -Value $quotedPath

            Write-Output ("Updated service '" + $serviceName + "' with quoted path: " + $quotedPath)
        }
    }
}
Write-Output "All unquoted service paths have been fixed."