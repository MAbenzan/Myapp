$url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.38.3-stable.zip"
$zipPath = "C:\src\flutter.zip"
$destPath = "C:\src"

Write-Host "Creating C:\src directory..."
New-Item -ItemType Directory -Force -Path $destPath | Out-Null

Write-Host "Downloading Flutter SDK from $url..."
Invoke-WebRequest -Uri $url -OutFile $zipPath

Write-Host "Extracting Flutter SDK..."
Expand-Archive -Path $zipPath -DestinationPath $destPath -Force

Write-Host "Cleaning up zip file..."
Remove-Item $zipPath

Write-Host "Adding Flutter to PATH..."
$currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)
if ($currentPath -notlike "*C:\src\flutter\bin*") {
    $newPath = $currentPath + ";C:\src\flutter\bin"
    [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::User)
    Write-Host "Flutter added to PATH."
} else {
    Write-Host "Flutter is already in PATH."
}

Write-Host "Installation Complete. Please restart your terminal."
