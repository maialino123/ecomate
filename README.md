# Ecomate System

Ecomate is a full-stack application with separate frontend and backend repositories managed as Git submodules.

## Project Structure

```
ecomate/
├── ecomate-fe/          # Frontend submodule
├── ecomate-be/          # Backend submodule
├── setup.bat            # Windows setup script
├── setup.sh             # Linux/Mac setup script
└── README.md            # This file
```

## Quick Start

### Option 1: Automatic Setup (Recommended)

**Windows:**
```bash
setup.bat
```

**Linux/Mac:**
```bash
./setup.sh
```

### Option 2: Manual Setup

If you've already cloned the repository without submodules, run:

```bash
git submodule update --init --recursive
```

### Option 3: Clone with Submodules

For new clones:

```bash
git clone --recurse-submodules <repository-url>
```

## Updating Submodules

To pull the latest changes from all submodules:

```bash
git submodule update --remote --recursive
```

## Submodules

- **ecomate-fe**: Frontend application
- **ecomate-be**: Backend application

## Notes

- The project includes a Git post-checkout hook that automatically updates submodules when switching branches
- Make sure you have SSH keys configured for GitHub to access the submodules
