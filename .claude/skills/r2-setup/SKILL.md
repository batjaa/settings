---
name: r2-setup
description: This skill should be used when the user asks to "set up R2", "configure Cloudflare R2", "add R2 storage", "set up S3-compatible storage", "configure cloud storage", or "fix R2 uploads" in a Laravel project.
disable-model-invocation: true
---

# Cloudflare R2 Setup for Laravel

Configure Cloudflare R2 as an S3-compatible storage disk in a Laravel project.

## Pre-flight Checks

1. Verify Laravel project
2. Check if R2 is already configured (search `.env` for `R2_` or `AWS_` with R2 endpoint)
3. Check if flysystem S3 adapter is installed: `composer show league/flysystem-aws-s3-v3`

## Installation

1. Install the S3 adapter:
   ```
   composer require league/flysystem-aws-s3-v3
   ```

2. Add R2 disk to `config/filesystems.php`:
   ```php
   'r2' => [
       'driver' => 's3',
       'key' => env('R2_ACCESS_KEY_ID'),
       'secret' => env('R2_SECRET_ACCESS_KEY'),
       'region' => 'auto',
       'bucket' => env('R2_BUCKET'),
       'endpoint' => env('R2_ENDPOINT'),
       'use_path_style_endpoint' => false,
   ],
   ```

3. Add to `.env`:
   ```
   MEDIA_DISK=r2
   R2_ACCESS_KEY_ID=
   R2_SECRET_ACCESS_KEY=
   R2_BUCKET=
   R2_ENDPOINT=https://<account-id>.r2.cloudflarestorage.com
   R2_CUSTOM_DOMAIN=
   ```

4. Use `MEDIA_DISK` env var throughout the app to switch between `local` and `r2`:
   ```php
   Storage::disk(config('filesystems.media_disk'))
   ```

5. Add to `config/filesystems.php`:
   ```php
   'media_disk' => env('MEDIA_DISK', 'local'),
   ```

## Serving Files

- For public files: use a Cloudflare R2 custom domain (set bucket to public, add custom domain in R2 dashboard)
- For private files: use `Storage::disk('r2')->temporaryUrl($path, now()->addMinutes(30))`
- Never use Flysystem internals (`getAdapter()`, `getClient()`) — they change across versions

## Custom Domain Setup

1. In Cloudflare R2 dashboard → bucket → Settings → Custom Domain
2. Add subdomain (e.g., `media.yourapp.com`)
3. Cloudflare auto-provisions SSL
4. Set `R2_CUSTOM_DOMAIN=media.yourapp.com` in `.env`
5. Generate public URLs: `"https://{$customDomain}/{$path}"`

## Local Development

- Set `MEDIA_DISK=local` in local `.env`
- Run `php artisan storage:link` for public disk access
- All code using `Storage::disk(config('filesystems.media_disk'))` works transparently

## Common Mistakes to Avoid

- Don't use `getAdapter()` or `getClient()` — Flysystem internals change between versions
- Don't hardcode disk names — use the `MEDIA_DISK` env var pattern
- Don't forget `use_path_style_endpoint => false` — R2 requires virtual-hosted style
- Don't confuse R2 public access (bucket-level) with Cloudflare site proxy settings — they can conflict
- Ensure `region` is set to `'auto'` for R2

## Post-Setup Verification

1. Test upload: `Storage::disk('r2')->put('test.txt', 'hello')`
2. Test read: `Storage::disk('r2')->get('test.txt')`
3. Test URL generation: `Storage::disk('r2')->temporaryUrl('test.txt', now()->addMinutes(5))`
4. Cleanup: `Storage::disk('r2')->delete('test.txt')`
