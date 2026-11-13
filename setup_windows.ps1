# ==============================================================================
# LumaLock Studio Suite — Windows PowerShell Bootstrap Script
# ------------------------------------------------------------------------------
# Clones or updates all 3 repositories inside .\apps\, installs frontend
# dependencies, and installs custom Antigravity skills into $HOME\.gemini\config\skills\
# ==============================================================================

$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AppsDir = Join-Path $RootDir "apps"
$SkillsDest = Join-Path $HOME ".gemini\config\skills"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  LumaLock Studio Suite - Windows Environment Setup" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Workspace Root: $RootDir"
Write-Host ""

# 1. Tooling checks
foreach ($cmd in @("git", "node", "npm", "cargo", "rustc")) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Host "[ERROR] Required tool missing: $cmd" -ForegroundColor Red
        Write-Host "Please install $cmd before continuing."
        exit 1
    }
}

Write-Host "[OK] Git:  $(git --version)"
Write-Host "[OK] Node: $(node --version) / npm $(npm --version)"
Write-Host "[OK] Rust: $(rustc --version)"
if (Get-Command gh -ErrorAction SilentlyContinue) {
    Write-Host "[OK] gh:   $(gh --version | Select-Object -First 1)"
} else {
    Write-Host "[WARN] GitHub CLI (gh) not found. Install via 'winget install GitHub.cli' if creating new repos." -ForegroundColor Yellow
}
Write-Host ""

# 2. Clone or update the 3 app repositories
New-Item -ItemType Directory -Force -Path $AppsDir | Out-Null

function Clone-Or-Pull($DirName, $RepoUrl) {
    $Target = Join-Path $AppsDir $DirName
    if (Test-Path (Join-Path $Target ".git")) {
        Write-Host "Updating $DirName..."
        git -C $Target pull --ff-only
    } else {
        Write-Host "Cloning $DirName from $RepoUrl..."
        git clone $RepoUrl $Target
    }
}

Clone-Or-Pull "lumalock-pro" "https://github.com/mixography-max/lumalock-pro.git"
Clone-Or-Pull "kantan-image-compression" "https://github.com/mixography-max/kantan-image-compression.git"
Clone-Or-Pull "KantanZIP" "https://github.com/mixography-max/KantanZIP.git"

Write-Host ""

# 3. Install npm dependencies for Tauri apps
foreach ($app in @("lumalock-pro", "kantan-image-compression")) {
    $PkgJson = Join-Path (Join-Path $AppsDir $app) "package.json"
    if (Test-Path $PkgJson) {
        Write-Host "Installing npm dependencies in apps/$app..."
        Push-Location (Join-Path $AppsDir $app)
        npm install
        Pop-Location
    }
}

Write-Host ""

# 4. Restore custom Antigravity skills
$SkillsSrc = Join-Path $RootDir "skills"
if (Test-Path $SkillsSrc) {
    New-Item -ItemType Directory -Force -Path $SkillsDest | Out-Null
    Copy-Item -Path (Join-Path $SkillsSrc "*") -Destination $SkillsDest -Recurse -Force
    Write-Host "Installed custom Antigravity skills to $SkillsDest" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host "Next steps:"
Write-Host "  1. Open Antigravity IDE."
Write-Host "  2. Open folder: $RootDir (or LumaLock_Suite.code-workspace)"
Write-Host "  3. Read HANDOVER_MANUAL.md and paste the Starter Prompt into Antigravity."
