#!/bin/bash

echo "====================================="
echo "   Ecomate Project Setup"
echo "====================================="
echo ""

echo "[1/3] Checking Git installation..."
if ! command -v git &> /dev/null; then
    echo "ERROR: Git is not installed"
    echo "Please install Git: https://git-scm.com/"
    exit 1
fi
echo "Git is installed!"
echo ""

echo "[2/3] Initializing and fetching submodules..."
if ! git submodule update --init --recursive; then
    echo "ERROR: Failed to fetch submodules"
    echo "Please check your SSH keys or network connection"
    exit 1
fi
echo ""

echo "[3/3] Verifying submodules..."
git submodule status
echo ""

echo "====================================="
echo "   Setup completed successfully!"
echo "====================================="
echo ""
echo "Your submodules are ready:"
echo "  - ecomate-fe (Frontend)"
echo "  - ecomate-be (Backend)"
echo ""
