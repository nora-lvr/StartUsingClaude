@echo off
rem Double-click this file to set up Python for reports on Windows.
rem It runs setup-windows.ps1 from this same folder.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-windows.ps1" %*
