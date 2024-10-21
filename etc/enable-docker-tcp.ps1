# Run this script as administrator

function Enable-DockerTCP {
    $dockerDesktopPath = "$env:APPDATA\Docker\settings.json"
    $dockerDaemonPath = "$env:ProgramData\Docker\config\daemon.json"

    if (Test-Path $dockerDesktopPath) {
        Write-Host "Docker Desktop detected. Configuring..."
        $config = Get-Content $dockerDesktopPath | ConvertFrom-Json
        $config.exposeDockerAPIOnTCP2375 = $true
        $config | ConvertTo-Json -Depth 10 | Set-Content $dockerDesktopPath
        Write-Host "Docker Desktop configured to expose daemon on TCP port 2375."
        Write-Host "Please restart Docker Desktop for the changes to take effect."
    }
    elseif (Test-Path $dockerDaemonPath) {
        Write-Host "Docker Engine detected. Configuring..."
        $config = Get-Content $dockerDaemonPath | ConvertFrom-Json
        if (-not $config) { $config = @{} }
        $config | Add-Member -Force -Name "hosts" -Value @("tcp://0.0.0.0:2375", "npipe://") -MemberType NoteProperty
        $config | ConvertTo-Json | Set-Content $dockerDaemonPath
        Restart-Service docker
        Write-Host "Docker Engine configured to listen on TCP port 2375. Docker service restarted."
    }
    else {
        Write-Host "Neither Docker Desktop nor Docker Engine configuration found. Is Docker installed?"
        return $false
    }
    return $true
}

# Run the function
Enable-DockerTCP