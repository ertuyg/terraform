# CloudFront Terraform Module

Bu modül, AWS CloudFront distribution'ları oluşturmak için kullanılır. Tek veya birden fazla S3 bucket'ı origin olarak destekler.

## Özellikler

- ✅ **Multi-Origin Desteği**: Birden fazla S3 bucket'tan içerik sunma
- ✅ **Dynamic Cache Behaviors**: Her path için özelleştirilebilir cache davranışları
- ✅ **Origin Access Control (OAC)**: S3 bucket'lara güvenli erişim
- ✅ **Otomatik OAC Oluşturma**: OAC verilmezse otomatik oluşturulur
- ✅ **Geri Dönük Uyumlu**: Mevcut tek-origin kullanımları çalışmaya devam eder
- ✅ **Esnek Konfigürasyon**: TTL, compression, protocol gibi ayarlar özelleştirilebilir

## Kullanım

### Senaryo 1: Basit Tek Origin (Legacy Mode)

Geri dönük uyumluluk için eski yapı hala desteklenmektedir:

```hcl
module "cloudfront" {
  source = "./cloudfront"

  bucket_name                = "my-static-website-bucket"
  s3_origin_id               = "S3-my-bucket"
  origin_access_control_name = "my-oac"

  aliases = ["www.example.com"]

  Environment = "production"
}
```

### Senaryo 2: Multi-Origin + Otomatik OAC

Birden fazla bucket'tan farklı içerik tipleri sunma:

```hcl
module "cloudfront" {
  source = "./cloudfront"

  origins = [
    {
      bucket_name = "images-bucket"
      origin_id   = "S3-images"
      origin_path = ""
      # OAC otomatik oluşturulur: "S3-images-oac"
    },
    {
      bucket_name = "videos-bucket"
      origin_id   = "S3-videos"
      # OAC otomatik oluşturulur: "S3-videos-oac"
    },
    {
      bucket_name = "static-assets-bucket"
      origin_id   = "S3-assets"
      origin_path = "/public"
      # OAC otomatik oluşturulur: "S3-assets-oac"
    }
  ]

  ordered_cache_behaviors = [
    {
      path_pattern           = "/images/*"
      target_origin_id       = "S3-images"
      viewer_protocol_policy = "redirect-to-https"
      compress               = true
      min_ttl                = 86400    # 1 gün
      default_ttl            = 604800   # 7 gün
      max_ttl                = 31536000 # 1 yıl
    },
    {
      path_pattern           = "/videos/*"
      target_origin_id       = "S3-videos"
      viewer_protocol_policy = "redirect-to-https"
      compress               = false
      allowed_methods        = ["GET", "HEAD"]
      min_ttl                = 3600     # 1 saat
      default_ttl            = 86400    # 1 gün
    },
    {
      path_pattern           = "/static/*"
      target_origin_id       = "S3-assets"
      viewer_protocol_policy = "redirect-to-https"
      compress               = true
      min_ttl                = 2592000  # 30 gün
    }
  ]

  aliases = ["cdn.example.com"]

  Environment = "production"
}
```

### Senaryo 3: Mevcut OAC Kullanımı

Daha önceden oluşturulmuş OAC'leri kullanma:

```hcl
module "cloudfront" {
  source = "./cloudfront"

  origins = [
    {
      bucket_name              = "shared-bucket"
      origin_id                = "S3-shared"
      origin_access_control_id = "E1234567890ABC"  # Mevcut OAC ID
    },
    {
      bucket_name                = "another-bucket"
      origin_id                  = "S3-another"
      origin_access_control_name = "custom-oac-name"  # Custom isimle yeni OAC oluştur
    },
    {
      bucket_name = "auto-oac-bucket"
      origin_id   = "S3-auto"
      # Ne ID ne de name verilmezse: "S3-auto-oac" adıyla oluşturulur
    }
  ]

  ordered_cache_behaviors = [
    {
      path_pattern     = "/api/*"
      target_origin_id = "S3-shared"
      query_string     = true  # Query string'leri cache'le
    }
  ]
}
```

## Variables

### Required Variables (Legacy Mode için)

Legacy mode kullanıyorsanız, `origins` boş bırakılıp aşağıdaki variable'lar kullanılmalıdır:

| Variable                     | Type   | Description                   |
| ---------------------------- | ------ | ----------------------------- |
| `bucket_name`                | string | S3 bucket adı                 |
| `s3_origin_id`               | string | Origin için unique identifier |
| `origin_access_control_name` | string | OAC adı                       |

### Optional Variables

| Variable                  | Type         | Default                                | Description                              |
| ------------------------- | ------------ | -------------------------------------- | ---------------------------------------- |
| `origins`                 | list(object) | `[]`                                   | Origin'lerin listesi (multi-origin mode) |
| `ordered_cache_behaviors` | list(object) | `[]`                                   | Cache behavior'ların listesi             |
| `aliases`                 | list(string) | `[]`                                   | CloudFront için domain alias'ları        |
| `Environment`             | string       | `"dev"`                                | Environment tag'i                        |
| `tags`                    | map(string)  | `{"Name" = "cloudfront distribution"}` | Resource tag'leri                        |

### Origins Object Yapısı

```hcl
{
  bucket_name                = string           # (required) S3 bucket adı
  origin_id                  = string           # (required) Unique origin ID
  origin_path                = string           # (optional) Bucket içinde path, default: ""
  origin_access_control_name = string           # (optional) OAC adı, verilmezse otomatik
  origin_access_control_id   = string           # (optional) Mevcut OAC ID'si
}
```

### Ordered Cache Behaviors Object Yapısı

```hcl
{
  path_pattern           = string           # (required) Path pattern örn: "/images/*"
  target_origin_id       = string           # (required) Hangi origin'e yönlendirilecek
  allowed_methods        = list(string)     # (optional) Default: ["GET", "HEAD", "OPTIONS"]
  cached_methods         = list(string)     # (optional) Default: ["GET", "HEAD"]
  compress               = bool             # (optional) Default: true
  viewer_protocol_policy = string           # (optional) Default: "redirect-to-https"
  min_ttl                = number           # (optional) Default: 0
  default_ttl            = number           # (optional) Default: 3600
  max_ttl                = number           # (optional) Default: 86400
  query_string           = bool             # (optional) Default: false
  cookies_forward        = string           # (optional) Default: "none"
}
```

## Origin Access Control (OAC) Stratejisi

Modül, 3 farklı OAC senaryosunu destekler:

1. **Otomatik OAC**: Hiçbir şey verilmezse `{origin_id}-oac` formatında oluşturulur
2. **Custom İsimli OAC**: `origin_access_control_name` verilirse o isimle oluşturulur
3. **Mevcut OAC**: `origin_access_control_id` verilirse mevcut OAC kullanılır

```hcl
# Örnek: Her 3 senaryoyu aynı anda kullanma
origins = [
  {
    bucket_name = "bucket1"
    origin_id   = "S3-bucket1"
    # OAC otomatik oluşturulur: "S3-bucket1-oac"
  },
  {
    bucket_name                = "bucket2"
    origin_id                  = "S3-bucket2"
    origin_access_control_name = "my-custom-oac"
    # "my-custom-oac" adıyla oluşturulur
  },
  {
    bucket_name              = "bucket3"
    origin_id                = "S3-bucket3"
    origin_access_control_id = "E2QWRTYUIOPASDF"
    # Mevcut OAC kullanılır
  }
]
```

## Outputs

| Output                                | Description                 |
| ------------------------------------- | --------------------------- |
| `cloudfront_distribution_id`          | CloudFront distribution ID  |
| `cloudfront_distribution_arn`         | CloudFront distribution ARN |
| `cloudfront_distribution_domain_name` | CloudFront domain name      |

## Notlar

### Default Cache Behavior

- Modül otomatik olarak bir `default_cache_behavior` oluşturur
- Legacy mode'da: `var.s3_origin_id` kullanır
- Multi-origin mode'da: İlk origin'i (`var.origins[0]`) kullanır
- Tüm diğer cache behavior'lar `ordered_cache_behaviors` ile tanımlanmalıdır

### S3 Bucket Policy

- Her origin için otomatik olarak S3 bucket policy oluşturulur
- CloudFront'un OAC ile bucket'a erişimine izin verir
- Bucket'ların önceden oluşturulmuş olması gerekir (modül bucket oluşturmaz)

### Path Pattern Önceliği

CloudFront, cache behavior'ları yukarıdan aşağıya sırayla kontrol eder:

1. `ordered_cache_behaviors` listesindeki sırayla
2. En sonda `default_cache_behavior`

Daha spesifik path'leri listenin üstüne koyun.

## Örnekler

### Image CDN

```hcl
module "image_cdn" {
  source = "./cloudfront"

  origins = [
    {
      bucket_name = "user-uploads-bucket"
      origin_id   = "S3-uploads"
    }
  ]

  ordered_cache_behaviors = [
    {
      path_pattern = "/avatars/*"
      target_origin_id = "S3-uploads"
      min_ttl     = 3600      # 1 saat
      default_ttl = 86400     # 1 gün
      max_ttl     = 604800    # 7 gün
      compress    = true
    },
    {
      path_pattern = "/products/*"
      target_origin_id = "S3-uploads"
      min_ttl     = 86400     # 1 gün
      default_ttl = 2592000   # 30 gün
      max_ttl     = 31536000  # 1 yıl
      compress    = true
    }
  ]

  aliases = ["images.example.com"]
}
```

### Multi-Region Asset Distribution

```hcl
module "global_cdn" {
  source = "./cloudfront"

  origins = [
    {
      bucket_name = "us-assets-bucket"
      origin_id   = "S3-us"
    },
    {
      bucket_name = "eu-assets-bucket"
      origin_id   = "S3-eu"
    }
  ]

  ordered_cache_behaviors = [
    {
      path_pattern     = "/us/*"
      target_origin_id = "S3-us"
      min_ttl          = 86400
    },
    {
      path_pattern     = "/eu/*"
      target_origin_id = "S3-eu"
      min_ttl          = 86400
    }
  ]

  aliases = ["cdn.example.com"]
}
```

## Migration Guide: Upgrading from Previous Version

If you're upgrading from the previous version of this module (single-origin without `for_each`), you'll need to migrate your Terraform state to avoid recreating resources.

### Why Migration is Needed

The module has been refactored from:

```hcl
resource "aws_cloudfront_origin_access_control" "this" { ... }
```

To:

```hcl
resource "aws_cloudfront_origin_access_control" "this" {
  for_each = local.oac_to_create
  ...
}
```

Terraform treats these as different resources, so without migration, it will try to destroy the old OAC and create a new one.

### Migration Steps

Run these commands in your project directory (where you call the cloudfront module):

#### Step 1: Find Your Origin ID

```bash
# Check your current configuration
grep s3_origin_id terraform.tfvars
# or
terraform state show 'module.cloudfront.aws_cloudfront_distribution.s3_distribution' | grep origin_id
```

Example output: `S3-my-bucket-name`

#### Step 2: Migrate State Resources

Replace `YOUR_ORIGIN_ID` with your actual origin ID from Step 1:

```bash
# Migrate OAC
terraform state mv \
  'module.cloudfront.aws_cloudfront_origin_access_control.this' \
  'module.cloudfront.aws_cloudfront_origin_access_control.this["YOUR_ORIGIN_ID"]'

# Migrate S3 bucket data source
terraform state mv \
  'module.cloudfront.data.aws_s3_bucket.this' \
  'module.cloudfront.data.aws_s3_bucket.this["YOUR_ORIGIN_ID"]'

# Migrate bucket policy
terraform state mv \
  'module.cloudfront.aws_s3_bucket_policy.cdn-oac-bucket-policy' \
  'module.cloudfront.aws_s3_bucket_policy.cdn-oac-bucket-policy["YOUR_ORIGIN_ID"]'

# Migrate IAM policy document
terraform state mv \
  'module.cloudfront.data.aws_iam_policy_document.s3_bucket_policy' \
  'module.cloudfront.data.aws_iam_policy_document.s3_bucket_policy["YOUR_ORIGIN_ID"]'
```

#### Step 3: Verify

```bash
terraform plan
```

You should see "No changes" or only minor attribute changes (not resource recreation).

### Example Migration

If your module call is:

```hcl
module "cloudfront" {
  source                     = "git::https://github.com/yourorg/terraform.git//cloudfront"
  bucket_name                = "my-docs-bucket"
  s3_origin_id               = "S3-my-docs-bucket"
  origin_access_control_name = "OAC-MyDocs"
}
```

Your migration commands would be:

```bash
terraform state mv \
  'module.cloudfront.aws_cloudfront_origin_access_control.this' \
  'module.cloudfront.aws_cloudfront_origin_access_control.this["S3-my-docs-bucket"]'

terraform state mv \
  'module.cloudfront.data.aws_s3_bucket.this' \
  'module.cloudfront.data.aws_s3_bucket.this["S3-my-docs-bucket"]'

terraform state mv \
  'module.cloudfront.aws_s3_bucket_policy.cdn-oac-bucket-policy' \
  'module.cloudfront.aws_s3_bucket_policy.cdn-oac-bucket-policy["S3-my-docs-bucket"]'

terraform state mv \
  'module.cloudfront.data.aws_iam_policy_document.s3_bucket_policy' \
  'module.cloudfront.data.aws_iam_policy_document.s3_bucket_policy["S3-my-docs-bucket"]'
```

### CI/CD Considerations

If you're using CI/CD (GitHub Actions, GitLab CI, etc.):

1. **Option A: Manual migration first**

   - Run migration commands locally
   - Commit the updated state (if using version-controlled state)
   - Let CI/CD run with already-migrated state

2. **Option B: Add migration step to CI/CD**

   - Add a migration job that runs before `terraform apply`
   - Use conditional logic to run migration only once

3. **Option C: Use remote state locking**
   - Lock the state
   - Run migration manually
   - Unlock and let CI/CD continue

### Troubleshooting

**Error: "Resource not found"**

- The resource name might be different in your setup
- Run `terraform state list | grep cloudfront` to see actual resource names

**Error: "Resource already exists at destination"**

- Migration already completed
- Run `terraform plan` to verify

**Error: "OriginAccessControlInUse"**

- This happens if you try to apply without migration
- Follow the migration steps above

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.0  |
| aws       | >= 4.0  |

## License

MIT
