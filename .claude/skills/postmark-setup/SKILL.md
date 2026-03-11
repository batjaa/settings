---
name: postmark-setup
description: This skill should be used when the user asks to "set up Postmark", "configure email", "add Postmark", "set up transactional email", "fix email sending", or "configure mail" in a Laravel project.
disable-model-invocation: true
---

# Postmark Setup for Laravel

Configure Postmark as the mail transport in a Laravel project using Symfony's Postmark bridge.

## Pre-flight Checks

1. Verify Laravel project
2. Check if Postmark is already configured (search `.env` for `POSTMARK` or `MAIL_MAILER=postmark`)
3. Check if required packages are installed: `composer show symfony/postmark-mailer` and `symfony/http-client`

## Installation

1. Install required packages:
   ```
   composer require symfony/postmark-mailer symfony/http-client
   ```

2. Update `.env`:
   ```
   MAIL_MAILER=postmark
   POSTMARK_TOKEN=your-server-api-token
   MAIL_FROM_ADDRESS=hello@yourapp.com
   MAIL_FROM_NAME="Your App"
   ```

3. Verify `config/mail.php` has the postmark transport (Laravel 11+ includes it by default):
   ```php
   'postmark' => [
       'transport' => 'postmark',
   ],
   ```

## Queue Configuration

Emails should be queued for performance. Ensure the queue is configured:

1. Set `QUEUE_CONNECTION=database` in `.env`
2. Run `php artisan queue:table && php artisan migrate` (if not already done)
3. Have all Mailable classes implement `ShouldQueue`:
   ```php
   class WelcomeEmail extends Mailable implements ShouldQueue
   ```
4. Ensure Forge queue worker is running (Forge → Site → Queue → Enable)

## Sender Signature

Before sending, verify the sender address in Postmark:
1. Go to Postmark → Sender Signatures
2. Add and verify `MAIL_FROM_ADDRESS`
3. For production, set up DKIM and Return-Path DNS records

## Testing Email Locally

1. Test via tinker:
   ```php
   Mail::raw('Test email body', function ($message) {
       $message->to('your@email.com')->subject('Test');
   });
   ```
2. Or use `MAIL_MAILER=log` locally and check `storage/logs/laravel.log`

## Common Mistakes to Avoid

- Don't forget `symfony/http-client` — `symfony/postmark-mailer` depends on it but doesn't auto-install it
- Don't use `MAIL_MAILER=smtp` with Postmark — use the native `postmark` transport
- Don't send emails synchronously on GET requests — always queue them
- Ensure the Postmark token is a **Server API Token**, not an Account API Token
- In production, verify the queue worker is running — queued emails silently fail if no worker processes them
- Don't forget to set `MAIL_FROM_ADDRESS` to a verified sender in Postmark

## Post-Setup Verification

1. Send a test email via tinker (see above)
2. Check Postmark dashboard → Activity for delivery status
3. If using queues, verify worker is processing: `php artisan queue:work --once`
4. Check `storage/logs/laravel.log` for any mail errors
