# Quick Start: Translation Module

## 🚀 Setup trong 5 phút

### 1. Deploy Cloudflare Worker

```bash
cd ecomate-translator
npm install
npx wrangler login
npm run deploy
```

Copy Worker URL sau khi deploy: `https://ecomate-translator.<subdomain>.workers.dev`

### 2. Configure Backend

Thêm vào `ecomate-be/.env`:

```env
CLOUDFLARE_WORKER_AI_URL=https://ecomate-translator.<your-subdomain>.workers.dev
TRANSLATION_CACHE_TTL=2592000
```

Run migration:

```bash
cd ecomate-be
npm run prisma:migrate:deploy
npm run prisma:generate
```

### 3. Start Services

**Backend:**
```bash
cd ecomate-be
npm run start:dev
```

**Frontend:**
```bash
cd ecomate-fe-v2
pnpm --filter admin dev
```

---

## 💡 Sử dụng ngay

### Option 1: Demo Page

1. Mở [http://localhost:3001/dashboard/translation-demo](http://localhost:3001/dashboard/translation-demo)
2. Click "Translate" button
3. Xem kết quả trong toast notification

### Option 2: Add vào Product Page

```tsx
import { TranslateButton } from '@/components/translation';

// Trong component của bạn:
<TranslateButton
  productId={product.id}
  onTranslateSuccess={() => window.location.reload()}
/>
```

### Option 3: API Call trực tiếp

```tsx
import { api } from '@workspace/lib';

const result = await api.translation.translateProduct('product-id');
console.log(result.translations.name?.translated);
```

---

## 📊 Monitor Usage

### Backend Cache Stats
```bash
curl http://localhost:8080/v1/translation/cache-stats \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Cloudflare Dashboard
https://dash.cloudflare.com → Workers & Pages → ecomate-translator

---

## ❓ Troubleshooting

**Q: Worker AI error 500**
A: Verify Cloudflare account has Workers AI enabled

**Q: Backend can't reach Worker**
A: Check `CLOUDFLARE_WORKER_AI_URL` in `.env`

**Q: "Too Many Requests" error**
A: Reached daily limit (10,000 neurons), resets at midnight UTC

**Q: Translation quality issues**
A: Model `m2m100-1.2b` has limitations for technical terms

---

## 📚 Full Documentation

- [Detailed Setup Guide](./TRANSLATION_SETUP.md)
- [Implementation Summary](./TRANSLATION_IMPLEMENTATION_SUMMARY.md)
- [Worker README](./ecomate-translator/README.md)
