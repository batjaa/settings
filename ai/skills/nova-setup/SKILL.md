---
name: nova-setup
description: This skill should be used when the user asks to "set up Nova", "install Nova", "add Nova admin", "configure Laravel Nova", or "add an admin panel" in a Laravel project.
disable-model-invocation: true
---

# Laravel Nova Setup

Install and configure Laravel Nova as the admin panel for a Laravel project.

## Pre-flight Checks

1. Verify Laravel project with `composer.json`
2. Check if Nova is already installed: `composer show laravel/nova` or search for `NovaServiceProvider`
3. Check for `auth.json` in project root (required for Nova's private Composer repository)

## Installation

### 1. Configure Composer Authentication

Nova requires a paid license. Add the private repository and credentials:

```bash
composer config repositories.nova '{"type": "composer", "url": "https://nova.laravel.com"}'
```

Create or update `auth.json` in the project root:
```json
{
    "http-basic": {
        "nova.laravel.com": {
            "username": "NOVA_USERNAME (license email)",
            "password": "NOVA_PASSWORD (license key)"
        }
    }
}
```

Ensure `auth.json` is in `.gitignore`.

### 2. Install Nova

```bash
composer require laravel/nova
php artisan nova:install
php artisan migrate
```

### 3. Configure NovaServiceProvider

In `app/Providers/NovaServiceProvider.php`:

```php
// Disable Nova's own auth routes to avoid conflict with Breeze/Fortify/Jetstream
protected function routes()
{
    Nova::routes()
        ->withAuthenticationRoutes(default: false)
        ->withPasswordResetRoutes()
        ->register();
}
```

### 4. Gate Authorization

In `NovaServiceProvider::gate()`, restrict access:
```php
Gate::define('viewNova', function ($user) {
    return in_array($user->email, [
        // admin emails
    ]);
});
```

### 5. Git & CI Configuration

- Add to `.gitignore`:
  ```
  /public/vendor
  auth.json
  ```
- Add `NOVA_USERNAME` and `NOVA_PASSWORD` as GitHub secrets for CI
- In GitHub Actions, create `auth.json` from secrets before `composer install`:
  ```yaml
  - name: Configure Nova
    run: |
      echo '{"http-basic":{"nova.laravel.com":{"username":"${{ secrets.NOVA_USERNAME }}","password":"${{ secrets.NOVA_PASSWORD }}"}}}' > auth.json
  ```

## Creating Resources

Generate a Nova resource for a model:
```bash
php artisan nova:resource Product
```

Resource conventions:
- Keep resource definitions clean — use Nova's built-in field types
- Use `BelongsTo`, `HasMany`, etc. for relationships
- Add filters, lenses, and actions as needed
- Use `Nova::withBreadcrumbs()` for navigation clarity

## Common Mistakes to Avoid

- Don't leave Nova's authentication routes enabled when using Breeze — route name `[login]` will conflict
- Don't commit `auth.json` — it contains license credentials
- Don't forget `/public/vendor` in `.gitignore` — Nova publishes assets there
- Don't override `register()` with an empty method in `NovaServiceProvider` — it breaks the parent's registration
- Don't forget to run `php artisan nova:publish` after updates

## Post-Setup Verification

1. Visit `/nova` in the browser
2. Confirm login works (via your app's existing auth, not Nova's)
3. Verify the dashboard loads without errors
4. Create a test resource and confirm it appears in the sidebar
