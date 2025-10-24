# Hướng dẫn Setup Translation Module

## Tổng quan

Module translation sử dụng **Cloudflare Worker AI** để dịch sản phẩm từ tiếng Trung sang tiếng Việt. Hệ thống bao gồm:

- **Cloudflare Worker**: Worker AI xử lý translation requests
- **Backend (NestJS)**: API endpoints và caching với Redis
- **Frontend (Next.js)**: UI components để trigger translation

---

## 1. Setup Cloudflare Worker AI

### Bước 1: Login vào Cloudflare

```bash
cd ecomate-translator
npx wrangler login
```

### Bước 2: Deploy Worker

```bash
npm run deploy
```

Sau khi deploy, bạn sẽ nhận được Worker URL:
```
https://ecomate-translator.<your-subdomain>.workers.dev
```

### Bước 3: Test Worker (Optional)

```bash
# Run locally
npm run dev

# Test với curl
curl -X POST http://localhost:8787 \
  -H "Content-Type: application/json" \
  -d '{"text": "这是一个产品", "sourceLang": "chinese", "targetLang": "vietnamese"}'
```

---

## 2. Setup Backend (NestJS)

### Bước 1: Update Environment Variables

Thêm vào file `.env`:

```env
# Cloudflare Worker AI
CLOUDFLARE_WORKER_AI_URL=https://ecomate-translator.<your-subdomain>.workers.dev
CLOUDFLARE_WORKER_AI_TOKEN=          # Optional - để trống nếu không dùng auth
CLOUDFLARE_ACCOUNT_ID=<your-account-id>
TRANSLATION_CACHE_TTL=2592000        # 30 days
```

### Bước 2: Run Database Migration

```bash
cd ecomate-be
npm run prisma:migrate:deploy
```

Migration sẽ thêm các fields:
- `nameZh` - Tên gốc tiếng Trung
- `descriptionZh` - Mô tả gốc tiếng Trung
- `translatedAt` - Timestamp của lần translate cuối
- `translationMeta` - Metadata về translation

### Bước 3: Regenerate Prisma Client

```bash
npm run prisma:generate
```

### Bước 4: Start Backend

```bash
npm run start:dev
```

Backend sẽ chạy tại `http://localhost:8080` với các endpoints:
- `POST /v1/translation/translate-product/:id` - Dịch 1 sản phẩm
- `POST /v1/translation/batch-translate` - Dịch nhiều sản phẩm
- `GET /v1/translation/cache-stats` - Xem thống kê cache

---

## 3. Setup Frontend (Next.js)

### Bước 1: Build packages

```bash
cd ecomate-fe-v2
pnpm build
```

### Bước 2: Start Admin App

```bash
pnpm --filter admin dev
```

Admin app sẽ chạy tại `http://localhost:3001`

---

## 4. Sử dụng Translation Components

### Translate Button (Single Product)

```tsx
import { TranslateButton } from '@/components/translation';

function ProductDetailPage({ productId }: { productId: string }) {
  return (
    <div>
      <h1>Product Details</h1>
      <TranslateButton
        productId={productId}
        onTranslateSuccess={(result) => {
          console.log('Translated:', result);
          // Refresh product data
          window.location.reload();
        }}
      />
    </div>
  );
}
```

### Batch Translate Button (Multiple Products)

```tsx
import { BatchTranslateButton } from '@/components/translation';

function ProductListPage({ selectedIds }: { selectedIds: string[] }) {
  return (
    <div>
      <h1>Products</h1>
      <BatchTranslateButton
        productIds={selectedIds}
        onTranslateSuccess={(result) => {
          console.log(`Translated ${result.successful} products`);
          // Refresh product list
        }}
      />
    </div>
  );
}
```

### Sử dụng API trực tiếp

```tsx
import { api } from '@workspace/lib';

async function translateProduct(productId: string) {
  try {
    const result = await api.translation.translateProduct(productId, {
      sourceLang: 'chinese',
      targetLang: 'vietnamese',
      forceRefresh: false, // Set true để bỏ qua cache
    });

    console.log('Original:', result.translations.name?.original);
    console.log('Translated:', result.translations.name?.translated);
    console.log('From cache:', result.cached);
  } catch (error) {
    console.error('Translation failed:', error);
  }
}
```

---

## 5. Caching Strategy

### Redis Cache

- **Key format**: `translation:zh-vi:{md5(text)}`
- **TTL**: 30 ngày (configurable via `TRANSLATION_CACHE_TTL`)
- **Stats keys**:
  - `translation:stats:hits` - Cache hit counter
  - `translation:stats:misses` - Cache miss counter

### Force Refresh

Để bỏ qua cache và dịch lại:

```tsx
const result = await api.translation.translateProduct(productId, {
  forceRefresh: true,
});
```

### Xem Cache Statistics

```tsx
const stats = await api.translation.getCacheStats();
console.log(`Hit rate: ${stats.hitRate}%`);
console.log(`Total requests: ${stats.totalRequests}`);
```

---

## 6. Cloudflare Free Tier Limits

- **10,000 neurons per day**
- Mỗi request translation ~ 1-10 neurons tùy độ dài text
- Nếu vượt limit, API sẽ trả về error 429 (Too Many Requests)

### Monitor Usage

1. Vào [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Chọn Workers & Pages → ecomate-translator
3. Xem tab "Metrics" để theo dõi usage

---

## 7. Testing

### Test Worker trực tiếp

```bash
curl -X POST https://ecomate-translator.<your-subdomain>.workers.dev \
  -H "Content-Type: application/json" \
  -d '{
    "text": "优质产品描述",
    "sourceLang": "chinese",
    "targetLang": "vietnamese"
  }'
```

### Test Backend API

```bash
# Login first to get token
TOKEN="your-jwt-token"

# Translate a product
curl -X POST http://localhost:8080/v1/translation/translate-product/cm123abc \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "sourceLang": "chinese",
    "targetLang": "vietnamese"
  }'
```

### Test Frontend

1. Mở Admin app: `http://localhost:3001`
2. Login với tài khoản admin
3. Tìm một sản phẩm có tên tiếng Trung
4. Click button "Translate"
5. Kiểm tra kết quả trong database

---

## 8. Troubleshooting

### Worker AI không hoạt động

**Lỗi**: "Worker AI returned 500"

**Giải pháp**:
1. Kiểm tra Cloudflare account có bật Workers AI chưa
2. Verify `wrangler.toml` có `[ai] binding = "AI"`
3. Redeploy worker: `npm run deploy`

### Backend không connect được Worker

**Lỗi**: "Translation failed: fetch failed"

**Giải pháp**:
1. Kiểm tra `CLOUDFLARE_WORKER_AI_URL` trong `.env`
2. Test Worker trực tiếp với curl
3. Kiểm tra CORS settings trong Worker

### Redis cache không hoạt động

**Lỗi**: "Redis connection failed"

**Giải pháp**:
1. Kiểm tra `REDIS_URL` trong `.env`
2. App vẫn chạy được nhưng không cache (mọi request sẽ gọi Worker AI)
3. Xem logs: `npm run start:dev` trong backend

### Frontend không gọi được API

**Lỗi**: "401 Unauthorized" hoặc "Network Error"

**Giải pháp**:
1. Kiểm tra user đã login chưa
2. Verify `NEXT_PUBLIC_API_BASE_URL` trong frontend
3. Kiểm tra CORS settings trong backend

---

## 9. Production Deployment

### Deploy Worker

```bash
cd ecomate-translator
npm run deploy
```

### Update Production .env

Thêm vào Railway/Vercel environment variables:

```env
CLOUDFLARE_WORKER_AI_URL=https://ecomate-translator.<subdomain>.workers.dev
CLOUDFLARE_WORKER_AI_TOKEN=<production-token>
TRANSLATION_CACHE_TTL=2592000
```

### Run Migration

```bash
npm run prisma:migrate:deploy
```

---

## 10. API Documentation

### POST /v1/translation/translate-product/:id

Translate một sản phẩm.

**Request Body** (Optional):
```json
{
  "sourceLang": "chinese",
  "targetLang": "vietnamese",
  "forceRefresh": false
}
```

**Response**:
```json
{
  "productId": "cm123abc456",
  "sku": "SKU-1688-001",
  "translations": {
    "name": {
      "original": "优质产品",
      "translated": "Sản phẩm chất lượng cao"
    },
    "description": {
      "original": "这是一个高品质的产品",
      "translated": "Đây là một sản phẩm chất lượng cao"
    }
  },
  "translatedAt": "2025-01-24T10:30:00Z",
  "cached": false
}
```

### POST /v1/translation/batch-translate

Translate nhiều sản phẩm cùng lúc.

**Request Body**:
```json
{
  "productIds": ["cm123abc", "cm456def"],
  "sourceLang": "chinese",
  "targetLang": "vietnamese",
  "forceRefresh": false
}
```

**Response**:
```json
{
  "total": 2,
  "successful": 2,
  "failed": 0,
  "results": [...],
  "errors": []
}
```

### GET /v1/translation/cache-stats

Lấy thống kê cache.

**Response**:
```json
{
  "cacheHits": 150,
  "cacheMisses": 50,
  "totalRequests": 200,
  "hitRate": 75
}
```

---

## Support

Nếu gặp vấn đề, tham khảo:
- [Cloudflare Workers AI Docs](https://developers.cloudflare.com/workers-ai/)
- [Wrangler CLI Docs](https://developers.cloudflare.com/workers/wrangler/)
- Backend logs: `npm run start:dev` trong `ecomate-be`
