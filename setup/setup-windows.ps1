# Sets up Python for making reports, on Windows.
# Run it by double-clicking setup-windows.bat (in this same folder).
#
# What it does:
#   1. Installs "uv", a small free tool that installs and manages Python.
#      No administrator rights needed; it installs only for your user account.
#   2. Uses uv to get Python and the report packages into a ".venv" folder
#      inside this repo. Nothing else on your computer is changed.
# Safe to run again: it skips anything that is already done.

param([switch]$NoPause)  # -NoPause: don't wait for Enter at the end (used when Claude runs it)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $RepoRoot

function Say($msg) { Write-Host ""; Write-Host $msg -ForegroundColor Cyan }
# Programs like uv report failure through an exit code, not an error; turn that into an error.
function Check($what) { if ($LASTEXITCODE -ne 0) { throw "Could not $what (exit code $LASTEXITCODE)." } }

try {
    Say "Step 1 of 3: Checking for uv (the Python installer)..."
    $uvDir = Join-Path $env:USERPROFILE ".local\bin"
    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        if (Test-Path (Join-Path $uvDir "uv.exe")) {
            $env:Path = "$uvDir;$env:Path"
        } else {
            Write-Host "Installing uv from astral.sh (the official source)..."
            Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression
            $env:Path = "$uvDir;$env:Path"
        }
    }
    uv --version; Check "run uv"

    Say "Step 2 of 3: Getting Python (this can take a few minutes the first time)..."
    if (-not (Test-Path ".venv\Scripts\python.exe")) {
        uv venv --python 3.12 .venv; Check "set up Python"
    } else {
        Write-Host "Python is already set up in .venv - skipping."
    }

    Say "Step 3 of 3: Installing report packages..."
    uv pip install --python .venv\Scripts\python.exe -r requirements.txt; Check "install the report packages"

    & .venv\Scripts\python.exe -c "import pandas, matplotlib, openpyxl, docx, fpdf; print('All report packages are working.')"
    Check "load the report packages"

    Write-Host ""
    Write-Host "Setup finished. Claude can now make reports for you." -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "Something went wrong during setup:" -ForegroundColor Red
    Write-Host $_
    Write-Host ""
    Write-Host "You can open Claude in this folder and paste the message above - Claude can help fix it."
    $failed = $true
}

if (-not $NoPause) {
    Write-Host ""
    Read-Host "Press Enter to close this window"
}

if ($failed) { exit 1 }
