# Query the system for unquoted service paths
#$services = Get-WmiObject -Query "SELECT Name, PathName FROM Win32_Service WHERE StartMode = 'Auto'"

foreach ($service in $services) {
    $serviceName = $service.Name
    $imagePath = $service.PathName.Trim()

    Write-Output ("Service Name: " + $serviceName)
    Write-Output ("Image Path: " + $imagePath)

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
Write-Output "All unquoted service paths have been fixed."
