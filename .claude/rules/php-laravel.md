---
paths:
  - "**/*.php"
  - "**/*.blade.php"
  - "**/composer.json"
  - "**/artisan"
---

## PHP / Laravel

**Architecture:**
- Keep controllers thin — validate, authorize, delegate. Business logic belongs in service classes or model methods.
- Authorize via Policies and `$this->authorize()`, not repeated inline `user_id` checks.
- Use PHP backed enums for columns with fixed values (statuses, types). No bare magic strings in controllers.
- Don't make synchronous external API calls on GET endpoints — cache locally or use webhooks.

**Eloquent:**
- Eager-load relations before mapping over collections. Define dedicated filtered relations (e.g., `completedPurchases()`) when needed.
- Combine multiple aggregates into one `selectRaw('SUM(...), COUNT(...), AVG(...)')`.
- Paginate at the database (`LIMIT`/cursor), never `->get()` all rows then `->slice()` in PHP.
- Bulk insert with `insert()` or `createMany()` — avoid N individual `create()` calls in loops.
- Load relations once after all mutations — don't `load()` mid-method and again at the end.
- When the same computed `array_merge` appears in multiple controllers, extract it to a model method.

**Migrations:**
- Add explicit `->index()` on every column used in `WHERE`/`JOIN`. Don't rely on FK constraints alone — behavior varies across DB drivers.

**Environment & Config:**
- Use `app()->isProduction()` / `app()->isLocal()` for environment checks. In tests, set environment via `$this->app['env'] = 'production'` (not `Config::set('app.env', ...)`  which only updates the config bag).
- Extract repeated `config(...)` calls (3+) to a private method or variable.

## Laravel + Forge + DigitalOcean

- **Storage**: Cloudflare R2 (S3-compatible). Use `MEDIA_DISK` env var to switch `local`/`r2`. Don't use Flysystem internals (`getAdapter`, `getClient`) — they change across versions.
- **Mail**: Postmark via `symfony/postmark-mailer` + `symfony/http-client`.
- **Queue**: `database` driver. Ensure Forge queue worker is configured.
- **Deployment**: Forge deploys to `~/site.app/current` (symlinked). Production `.env` lives there.
- **Nova**: Requires paid license + `auth.json`. Set `withAuthenticationRoutes(default: false)` to avoid Breeze route conflict. Add `NOVA_USERNAME`/`NOVA_PASSWORD` as GitHub secrets. Add `/public/vendor` to `.gitignore`.
- **Setup skills**: Use `/stripe-setup`, `/r2-setup`, `/postmark-setup`, `/nova-setup` for guided integration setup.
