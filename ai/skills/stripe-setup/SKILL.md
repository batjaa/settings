---
name: stripe-setup
description: This skill should be used when the user asks to "set up Stripe", "configure Stripe", "add Stripe payments", "integrate Stripe Cashier", "set up Stripe Connect", or "configure Stripe webhooks" in a Laravel project.
disable-model-invocation: true
argument-hint: [cashier|connect|checkout]
---

# Stripe Setup for Laravel

Configure Stripe integration in a Laravel project. Argument determines the integration type:
- `cashier` (default) — Subscriptions via Laravel Cashier
- `connect` — Stripe Connect for marketplace payouts
- `checkout` — One-time payments via Stripe Checkout

## Pre-flight Checks

1. Verify Laravel project with `composer.json`
2. Check if Stripe is already configured (search `.env` for `STRIPE_`)
3. Check if Cashier is already installed (`composer show laravel/cashier` or search `composer.json`)

## Cashier Setup (subscriptions)

1. Install: `composer require laravel/cashier`
2. Run: `php artisan vendor:publish --tag=cashier-migrations && php artisan migrate`
3. Add `Billable` trait to User model
4. Add to `.env`:
   ```
   STRIPE_KEY=pk_test_...
   STRIPE_SECRET=sk_test_...
   STRIPE_WEBHOOK_SECRET=whsec_...
   ```
5. Create webhook route (exclude from CSRF):
   ```php
   // routes/web.php — inside middleware group without VerifyCsrfToken
   Route::post('/stripe/webhook', [WebhookController::class, 'handleWebhook']);
   ```
6. Register webhook events the app should handle:
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
   - `checkout.session.completed`
7. Add webhook secret to `phpunit.xml` for CI if tests hit Stripe

## Connect Setup (marketplace payouts)

1. Install Cashier if not present (see above)
2. Add migration for `stripe_account_id` on the payee model (e.g., `users` or `photographers`)
3. Implement onboarding flow:
   - Create account link via `Stripe\AccountLink::create()`
   - Handle return/refresh URLs
   - Store `stripe_account_id` on success
4. Add to `.env`:
   ```
   STRIPE_CONNECT_ACCOUNT_ID=  # Platform account
   ```
5. Verify Connect webhook events are registered:
   - `account.updated`
   - `transfer.created`

## Checkout Setup (one-time payments)

1. Install Cashier if not present
2. Create Checkout session with line items and success/cancel URLs
3. Handle `checkout.session.completed` webhook to fulfill the order
4. Use `temporaryUrl()` or signed routes for post-payment access if delivering digital goods

## Local Webhook Testing

1. Install Stripe CLI: `brew install stripe/stripe-cli/stripe`
2. Login: `stripe login`
3. Forward: `stripe listen --forward-to localhost:8000/stripe/webhook`
4. Copy the webhook signing secret from output into `.env` as `STRIPE_WEBHOOK_SECRET`
5. Trigger test events: `stripe trigger payment_intent.succeeded`

## Common Mistakes to Avoid

- Never use raw `stripe/stripe-php` when Cashier provides the method — Cashier handles idempotency, webhooks, and edge cases
- Always exclude the webhook route from CSRF verification
- Always verify webhook signatures (Cashier does this by default)
- Create Stripe products/prices in the correct Stripe account (test vs live, correct business)
- Add `STRIPE_KEY` and `STRIPE_SECRET` to CI environment for tests that need them

## Post-Setup Verification

1. Run `php artisan tinker` and verify `\Stripe\Stripe::$apiKey` is set
2. Hit the webhook endpoint with `stripe trigger checkout.session.completed`
3. Confirm webhook handler processes the event (check logs)
