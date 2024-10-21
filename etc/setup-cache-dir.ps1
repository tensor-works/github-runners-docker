function Format-DockerPath {
    param([string]$path)
    $path = $path -replace '^([A-Za-z]):', '/$1'
    $path = $path -replace '\\', '/'
    return $path.ToLower()
}

function Format-WindowsPath {
    param([string]$path)
    return $path -replace '^/([a-z])', '$1:' -replace '/', '\'
}

$defaultCacheDir = Join-Path $env:USERPROFILE '.github-action-cache'

$existingCacheDir = if (Test-Path .env) {
    $content = Get-Content .env -Raw
    $match = [regex]::Match($content, 'DOCKER_CACHE_DIR=(.*)')
    if ($match.Success) { $match.Groups[1].Value.Trim() }
}

if ($existingCacheDir) {
    Write-Host "DOCKER_CACHE_DIR already exists in .env file: $existingCacheDir"
    $formattedPath = Format-DockerPath $existingCacheDir
    (Get-Content .env) -replace 'DOCKER_CACHE_DIR=.*', "DOCKER_CACHE_DIR=$formattedPath" | Set-Content .env
    Write-Host "Updated DOCKER_CACHE_DIR in .env file to: $formattedPath"
    $dirToCreate = Format-WindowsPath $formattedPath
} else {
    $cachedir = Read-Host "Enter GitHub Actions cache directory (default: $defaultCacheDir)"
    if (-not $cachedir) { $cachedir = $defaultCacheDir }
    $formattedPath = Format-DockerPath $cachedir
    if (-not (Test-Path .env -PathType Leaf)) { New-Item .env -ItemType File }
    Add-Content -Path .env -Value "DOCKER_CACHE_DIR=$formattedPath"
    Write-Host "Added DOCKER_CACHE_DIR=$formattedPath to .env file"
    $dirToCreate = $cachedir
}

try {
    if (-not (Test-Path -LiteralPath $dirToCreate)) {
        New-Item -Path $dirToCreate -ItemType Directory -Force
        Write-Host "Created directory: $dirToCreate"
    } else {
        Write-Host "Directory already exists: $dirToCreate"
    }
} catch {
    Write-Host "Error creating directory: $_"
}

Write-Host "GitHub Actions cache directory setup complete."