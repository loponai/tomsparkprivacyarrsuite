# Privacy Box - Web Installer
# Usage: irm https://raw.githubusercontent.com/loponai/tomsparkprivacyarrsuite/main/install.ps1 | iex

$repo = "loponai/tomsparkprivacyarrsuite"
$branch = "main"
$installDir = "$env:USERPROFILE\Desktop\PrivacyServer"

Write-Host ""
Write-Host "  Privacy Box Installer" -ForegroundColor Cyan
Write-Host "  =====================" -ForegroundColor Cyan
Write-Host ""

# Create directory
Write-Host "  [1/3] Creating directory..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $installDir -Force | Out-Null

# Download files
Write-Host "  [2/3] Downloading files..." -ForegroundColor Yellow

$files = @(
    "privacy-box-setup.ps1",
    "Setup-PrivacyBox.bat",
    "docker-compose.yml",
    ".env.example"
)

$baseUrl = "https://raw.githubusercontent.com/$repo/$branch"

foreach ($file in $files) {
    $url = "$baseUrl/$file"
    $dest = "$installDir\$file"
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
        Write-Host "       Downloaded: $file" -ForegroundColor Gray
    }
    catch {
        Write-Host "       Failed: $file" -ForegroundColor Red
    }
}

# Rename example to template
if (Test-Path "$installDir\.env.example") {
    Copy-Item "$installDir\.env.example" "$installDir\.env.template" -Force
}

Write-Host "  [3/3] Done!" -ForegroundColor Green
Write-Host ""
Write-Host "  Files installed to: $installDir" -ForegroundColor White
Write-Host ""
Write-Host "  Next step: Open that folder and double-click 'Setup-PrivacyBox.bat'" -ForegroundColor Yellow
Write-Host ""

# Open the folder
explorer.exe $installDir
