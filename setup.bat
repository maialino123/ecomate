@echo off
echo =====================================
echo   Ecomate Project Setup
echo =====================================
echo.

echo [1/3] Checking Git installation...
git --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Git is not installed or not in PATH
    echo Please install Git from https://git-scm.com/
    pause
    exit /b 1
)
echo Git is installed!
echo.

echo [2/3] Initializing and fetching submodules...
git submodule update --init --recursive
if errorlevel 1 (
    echo ERROR: Failed to fetch submodules
    echo Please check your SSH keys or network connection
    pause
    exit /b 1
)
echo.

echo [3/3] Verifying submodules...
git submodule status
echo.

echo =====================================
echo   Setup completed successfully!
echo =====================================
echo.
echo Your submodules are ready:
echo   - ecomate-fe (Frontend)
echo   - ecomate-be (Backend)
echo.
pause