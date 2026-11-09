#!/bin/bash
# Sets up Python for making reports, on a Mac.
# Run it by double-clicking this file. If the Mac says it can't be opened,
# right-click it, choose Open, then click Open again.
#
# What it does:
#   1. Installs "uv", a small free tool that installs and manages Python.
#      No administrator password needed; it installs only for your user account.
#   2. Uses uv to get Python and the report packages into a ".venv" folder
#      inside this repo. Nothing else on your computer is changed.
# Safe to run again: it skips anything that is already done.

cd "$(dirname "$0")/.." || exit 1

say() { echo; echo "== $1"; }
fail() {
  echo
  echo "Something went wrong during setup: $1"
  echo "You can open Claude in this folder and paste the message above - Claude can help fix it."
  echo
  read -r -p "Press Enter to close this window"
  exit 1
}

say "Step 1 of 3: Checking for uv (the Python installer)..."
export PATH="$HOME/.local/bin:$PATH"
if ! command -v uv >/dev/null 2>&1; then
  echo "Installing uv from astral.sh (the official source)..."
  curl -LsSf https://astral.sh/uv/install.sh | sh || fail "could not install uv"
fi
uv --version || fail "uv is not working"

say "Step 2 of 3: Getting Python (this can take a few minutes the first time)..."
if [ ! -x ".venv/bin/python" ]; then
  uv venv --python 3.12 .venv || fail "could not set up Python"
else
  echo "Python is already set up in .venv - skipping."
fi

say "Step 3 of 3: Installing report packages..."
uv pip install --python .venv/bin/python -r requirements.txt || fail "could not install packages"

.venv/bin/python -c "import pandas, matplotlib, openpyxl, docx, fpdf; print('All report packages are working.')" \
  || fail "packages installed but did not load"

echo
echo "Setup finished. Claude can now make reports for you."
echo
read -r -p "Press Enter to close this window"
