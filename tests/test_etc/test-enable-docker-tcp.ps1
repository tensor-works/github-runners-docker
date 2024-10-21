# Run this script as administrator

function Test-DockerTCPConfig {
    $dockerDesktopPath = "$env:APPDATA\Docker\settings.json"
    $dockerDaemonPath = "$env:ProgramData\Docker\config\daemon.json"

    if (Test-Path $dockerDesktopPath) {
        Write-Host "Testing Docker Desktop configuration..."
        $config = Get-Content $dockerDesktopPath | ConvertFrom-Json
        if ($config.exposeDockerAPIOnTCP2375 -eq $true) {
            Write-Host "Docker Desktop is correctly configured to expose daemon on TCP port 2375."
            return $true
        }
        else {
            Write-Host "Docker Desktop is not configured to expose daemon on TCP port 2375."
            return $false
        }
    }
    elseif (Test-Path $dockerDaemonPath) {
        Write-Host "Testing Docker Engine configuration..."
        $config = Get-Content $dockerDaemonPath | ConvertFrom-Json
        if ($config.hosts -and $config.hosts -contains "tcp://0.0.0.0:2375") {
            Write-Host "Docker Engine is correctly configured to listen on TCP port 2375."
            return $true
        }
        else {
            Write-Host "Docker Engine is not configured to listen on TCP port 2375."
            return $false
        }
    }
    else {
        Write-Host "Neither Docker Desktop nor Docker Engine configuration found. Is Docker installed?"
        return $false
    }
}

# Run the test
$result = Test-DockerTCPConfig
if ($result) {
    Write-Host "Test passed: Docker is correctly configured for TCP access."
    exit 0
} else {
    Write-Host "Test failed: Docker is not correctly configured for TCP access."
    exit 1
}