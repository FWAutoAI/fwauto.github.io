#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Color helpers
function Write-Info  { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Green }
function Write-Warn  { param($msg) Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err   { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }

# Check uv
function Test-Uv {
    $uv = Get-Command uv -ErrorAction SilentlyContinue
    if (-not $uv) {
        Write-Err "uv is not installed"
        Write-Host ""
        Write-Host "Please install uv first:"
        Write-Host "  powershell -ExecutionPolicy ByPass -c `"irm https://astral.sh/uv/install.ps1 | iex`""
        Write-Host ""
        return $false
    }
    $version = & uv --version | Select-Object -First 1
    Write-Info "uv installed: $version"
    return $true
}

# Check Node.js version
function Test-Node {
    $node = Get-Command node -ErrorAction SilentlyContinue
    if (-not $node) {
        Write-Err "Node.js is not installed"
        Write-Host ""
        Write-Host "Please install Node.js >= 20:"
        Write-Host "  https://nodejs.org/"
        Write-Host ""
        return $false
    }

    $version = (& node --version) -replace '^v', ''
    $major = [int]($version -split '\.')[0]

    if ($major -lt 20) {
        Write-Err "Node.js version too old: v$version (requires >= 20)"
        return $false
    }

    Write-Info "Node.js installed: v$version"
    return $true
}

# Install fwauto
function Install-FWAuto {
    Write-Info "Installing fwauto (this may take a while)..."
    & uv tool install --quiet --force --prerelease=allow fwauto
    if ($LASTEXITCODE -ne 0) { throw "fwauto installation failed" }
    Write-Info "fwauto installation complete"
}

# Install npm tool
function Install-NpmTool {
    param($Cmd, $Package)
    $existing = Get-Command $Cmd -ErrorAction SilentlyContinue
    if ($existing) {
        $ver = & $Cmd --version 2>$null | Select-Object -First 1
        Write-Info "$Cmd installed: $ver"
        return
    }
    & npm install -g --silent $Package
    if ($LASTEXITCODE -ne 0) { throw "Failed to install $Package" }
}

# Install AI tools
function Install-AITools {
    Write-Host ""
    Write-Info "Installing AI CLI tools (this may take a while)..."
    Write-Host ""
    Install-NpmTool "claude" "@anthropic-ai/claude-code"
}

# Main
function Main {
    Write-Host "=========================================="
    Write-Host "  FWAuto Installation Script (Windows)"
    Write-Host "=========================================="
    Write-Host ""

    Write-Info "Checking environment..."
    Write-Host ""

    $hasError = $false
    if (-not (Test-Uv))   { $hasError = $true }
    if (-not (Test-Node))  { $hasError = $true }

    if ($hasError) {
        Write-Host ""
        Write-Err "Environment check failed, please install missing tools first"
        exit 1
    }

    Write-Host ""
    Write-Info "Environment check passed!"

    Write-Host ""
    Install-FWAuto

    Install-AITools

    Write-Host ""
    Write-Host "=========================================="
    Write-Info "Installation complete!"
    Write-Host "=========================================="
    Write-Host ""
    Write-Host "Run the following command to verify installation:"
    Write-Host "  fwauto --help"
    Write-Host ""
}

Main
