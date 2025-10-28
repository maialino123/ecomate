# Ecomate System

Ecomate is a comprehensive e-commerce platform for managing 1688 product imports with AI-powered translation capabilities.

## Project Structure

```
ecomate/
├── ecomate-fe/              # Frontend (Legacy)
├── ecomate-fe-v2/           # Frontend v2 (Active - Turborepo monorepo)
│   ├── apps/
│   │   ├── admin/          # Admin dashboard
│   │   ├── web/            # Customer-facing app
│   │   └── landing/        # Landing page
│   └── packages/
│       ├── ui/             # Shared UI components
│       ├── lib/            # API client & utilities
│       └── shared/         # Shared business logic
├── ecomate-be/              # Backend (NestJS)
│   ├── src/modules/
│   │   ├── auth/           # Authentication
│   │   ├── product/        # Product management
│   │   ├── supplier/       # Supplier management
│   │   ├── cost/           # Cost calculation
│   │   ├── translation/    # Translation API (NEW!)
│   │   └── ...
│   └── prisma/             # Database schema
├── ecomate-translator/      # Cloudflare Worker AI (NEW!)
│   ├── src/index.ts        # Translation worker
│   └── wrangler.toml       # Worker config
├── setup.bat               # Windows setup script
├── setup.sh                # Linux/Mac setup script
└── README.md               # This file
```

## Quick Start

### Option 1: Automatic Setup (Recommended)

**Windows:**
```bash
setup.bat
```

**Linux/Mac:**
```bash
chmod +x setup.sh
./setup.sh
```

This will:
1. Initialize all Git submodules
2. Fetch latest code from all repositories

### Option 2: Manual Setup

If you've already cloned the repository without submodules:

```bash
git submodule update --init --recursive
```

### Option 3: Clone with Submodules

For new clones:

```bash
git clone --recurse-submodules git@github.com:maialino123/ecomate.git
```

## Installation

After setting up submodules, install dependencies for each component:

### Backend
```bash
cd ecomate-be
npm install
npm run prisma:generate
```

### Frontend (v2)
```bash
cd ecomate-fe-v2
pnpm install
```

### Cloudflare Worker (Translation)
```bash
cd ecomate-translator
npm install
```

## Running the Application

### Backend (Port 8080)
```bash
cd ecomate-be
npm run start:dev
```

### Admin Dashboard (Port 3001)
```bash
cd ecomate-fe-v2
pnpm --filter admin dev
```

### Web App (Port 3000)
```bash
cd ecomate-fe-v2
pnpm --filter web dev
```

### Translation Worker (Local)
```bash
cd ecomate-translator
npm run dev
```

## Deploying Translation Worker

The Cloudflare Worker auto-deploys via GitHub Actions when you push to `main`:

```bash
cd ecomate-translator
git add .
git commit -m "Update translation logic"
git push origin main
```

Or deploy manually:
```bash
cd ecomate-translator
npm run deploy
```

### Required Secrets

Add these to `ecomate-translator` repository settings:
- `CLOUDFLARE_API_TOKEN` - From Cloudflare Dashboard
- `CLOUDFLARE_ACCOUNT_ID` - Your Cloudflare Account ID

## Submodules

| Repository | Description | Tech Stack |
|------------|-------------|------------|
| **[ecomate-fe](https://github.com/maialino123/ecomate-fe)** | Frontend Legacy | Next.js |
| **[ecomate-fe-v2](https://github.com/maialino123/ecomate-fe-v2)** | Frontend v2 (Active) | Next.js 15, Turborepo, pnpm |
| **[ecomate-be](https://github.com/maialino123/ecomate-be)** | Backend API | NestJS, Prisma, PostgreSQL, Redis |
| **[ecomate-translator](https://github.com/maialino123/ecomate-translator)** | Translation Worker | Cloudflare Workers AI |

## Features

### Backend
- ✅ User authentication with JWT & 2FA
- ✅ Product management (CRUD, inventory)
- ✅ 1688 supplier integration
- ✅ Vietnamese cost calculation engine
- ✅ **AI Translation API** (Chinese → Vietnamese)
- ✅ Cloudflare R2 storage
- ✅ Redis caching

### Frontend (Admin)
- ✅ Admin dashboard
- ✅ Product management UI
- ✅ Cost calculation forms
- ✅ **Translation UI components**
- ✅ User management
- ✅ Registration approval system

### Translation System (NEW!)
- ✅ Cloudflare Worker AI powered
- ✅ Chinese → Vietnamese translation
- ✅ Redis cache (30-day TTL)
- ✅ Batch translation support
- ✅ Free tier: 10,000 neurons/day
- ✅ Auto-deploy via GitHub Actions

## Documentation

- [Translation Setup Guide](./TRANSLATION_SETUP.md) - Full translation module setup
- [Translation Quick Start](./TRANSLATION_QUICK_START.md) - 5-minute setup guide
- [Translation Implementation](./TRANSLATION_IMPLEMENTATION_SUMMARY.md) - Technical details

## Updating Submodules

To pull the latest changes from all submodules:

```bash
git submodule update --remote --recursive
```

To update a specific submodule:

```bash
cd ecomate-translator
git pull origin main
cd ..
git add ecomate-translator
git commit -m "Update translator submodule"
```

## Architecture

```
┌─────────────────┐
│  Admin UI       │
│  (Next.js)      │
│  Port: 3001     │
└────────┬────────┘
         │ HTTP
         ▼
┌─────────────────┐      ┌──────────────────┐
│  Backend API    │◄────►│  Redis Cache     │
│  (NestJS)       │      │  (Translation)   │
│  Port: 8080     │      └──────────────────┘
└────────┬────────┘
         │ HTTP
         ▼
┌─────────────────┐
│ Cloudflare      │
│ Worker AI       │
│ (Translation)   │
└─────────────────┘
```

## Environment Setup

### Backend (.env)
```env
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
CLOUDFLARE_WORKER_AI_URL=https://ecomate-translator.<subdomain>.workers.dev
TRANSLATION_CACHE_TTL=2592000
```

### Frontend (.env.local)
```env
NEXT_PUBLIC_API_BASE_URL=http://localhost:8080
```

## Notes

- The project includes a Git post-checkout hook that automatically updates submodules
- Make sure you have SSH keys configured for GitHub to access the submodules
- Translation worker requires Cloudflare account with Workers AI enabled
- Use pnpm for frontend v2, npm for backend and worker

## Troubleshooting

### Submodule Issues
```bash
# Reset all submodules
git submodule deinit -f .
git submodule update --init --recursive
```

### Translation Worker Not Deploying
1. Check GitHub Secrets are set correctly
2. Verify Cloudflare API token permissions
3. Check GitHub Actions logs

## License

MIT

---

**🤖 Monorepo managed with Git Submodules**
