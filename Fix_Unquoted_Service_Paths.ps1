# Execute WMIC command in CMD to filter unquoted auto-start services
$services = cmd /c 'wmic service get Name,PathName,DisplayName,StartMode | findstr /i auto | findstr /i /v "C:\Windows\\" | findstr /i /v "\""' 

# Convert output into an array
$services = $services -split "`r`n"

foreach ($line in $services) {
    # Skip empty lines
    if ($line -match "^\s*$") { continue }

    # Split based on excessive spaces (handles inconsistent WMIC spacing)
    $parts = $line -split '\s{2,}'

    if ($parts.Count -ge 2) {
        $serviceName = $parts[0].Trim()
        $imagePath = $parts[1].Trim()

        # Ensure the path is unquoted and contains spaces
        if ($imagePath -match "\s" -and $imagePath -notmatch '^".*"$') {
            Write-Output "🔍 Fixing unquoted path for service: $serviceName"

            # Add quotes around the path
            $quotedPath = '"' + $imagePath + '"'

            # Build the correct registry path
            $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$serviceName"

            # Check if registry path exists before modifying
            if (Test-Path $registryPath) {
                # Perform the registry update
                Set-ItemProperty -Path $registryPath -Name ImagePath -Value $quotedPath -Verbose
                Write-Output "✅ Updated service '$serviceName' with quoted path: $quotedPath"
            } else {
                Write-Output "⚠️ Registry path not found: $registryPath (Skipping)"
            }
        }
    }
}

Write-Output "✅ All unquoted service paths have been fixed."
