# CI/CD Secrets Setup Guide

This document explains every GitHub Actions secret required by
`.github/workflows/analyze_test_build.yml` for the `Deploy to TestFlight` and
`Deploy to Firebase App Distribution` jobs to actually run, where to obtain
each value, and how to add it safely.

**Never paste real secret values into a chat session, a commit, or any file
in this repository.** Add them only through GitHub's own UI (or `gh secret
set`, run locally by you, which also never echoes the value back). All
secrets below are added the same way:

> Repository → **Settings** → **Secrets and variables** → **Actions** →
> **New repository secret** → paste the name and value → **Add secret**

Prerequisites you need before any of this is possible:
- An **Apple Developer Program** membership ($99/year) — required for the
  `Build iOS IPA` and `Deploy to TestFlight` jobs.
- A **Firebase project** for this app, with an Android app registered in it
  — required for `Deploy to Firebase App Distribution`. See
  `FIREBASE_SETUP.md` for creating the project itself if you haven't yet.

---

## Why 9 secrets, not the original list of 6

The workflow's TestFlight job called `fastlane beta`, but the repo had no
`Fastfile`/`Appfile`/`Gemfile` and no certificate-import step — so even with
the originally-named secrets (`APPLE_DEVELOPER_CERTIFICATE_ID`,
`FASTLANE_USER`/`PASSWORD`, etc.) it would still have failed. That
scaffolding has now been added (`ios/Gemfile`, `ios/fastlane/Appfile`,
`ios/fastlane/Fastfile`, plus a certificate-import step in the workflow),
built around an **App Store Connect API Key** instead of an Apple ID +
password — the API key doesn't expire and isn't blocked by two-factor
authentication, so it won't randomly break future CI runs the way a
username/password login does. That changed which secrets are needed.

---

## Apple / TestFlight secrets (4)

### 1. `APPLE_DEVELOPER_TEAM_ID`
Your 10-character Apple Developer Team ID.
- Go to https://developer.apple.com/account
- **Membership details** → **Team ID**

### 2. `APPLE_CERTIFICATE_BASE64`
A base64-encoded **Apple Distribution** certificate (`.p12` file), used to
code-sign the release build in CI.

1. On a Mac, open **Keychain Access** → **Certificate Assistant** →
   **Request a Certificate from a Certificate Authority** to generate a CSR
   (or use Xcode: **Settings → Accounts → Manage Certificates → + → Apple
   Distribution**, which does this for you).
2. In https://developer.apple.com/account/resources/certificates/list,
   create a new **Apple Distribution** certificate, uploading the CSR if you
   made one manually. Download the resulting `.cer` and double-click it to
   install it into Keychain Access (it pairs with the private key already
   there from step 1).
3. In Keychain Access, find the certificate under **My Certificates**,
   right-click → **Export...** → save as `certificate.p12`. Set an export
   password — you'll need it for the next secret.
4. Base64-encode it and copy the result:
   ```bash
   base64 -i certificate.p12 | pbcopy
   ```
5. Paste the copied text as the secret value.

### 3. `APPLE_CERTIFICATE_PASSWORD`
The export password you chose in step 3 above (not your Apple ID password).

### 4. `APPLE_PROVISIONING_PROFILE_BASE64`
A base64-encoded **App Store** provisioning profile for this app.

1. In https://developer.apple.com/account/resources/identifiers/list,
   register an App ID with bundle identifier `com.zkaz.toriverse` if it
   doesn't already exist.
2. In https://developer.apple.com/account/resources/profiles/list, create a
   new profile → **App Store Connect** distribution type → select the
   `com.zkaz.toriverse` App ID → select your Distribution certificate from
   step 2 above → name it and download the `.mobileprovision` file.
3. Base64-encode it:
   ```bash
   base64 -i Toriverse_App_Store.mobileprovision | pbcopy
   ```
4. Paste the copied text as the secret value.

---

## App Store Connect API Key secrets (3)

Used by Fastlane to authenticate and upload the build to TestFlight, instead
of an Apple ID + password.

1. Go to https://appstoreconnect.apple.com/access/api
   (requires the Admin role on your App Store Connect team).
2. Click **Generate API Key** (or **+**), name it (e.g. "GitHub Actions CI"),
   give it the **App Manager** role.
3. Note the **Key ID** and **Issuer ID** shown on that page.
4. Download the `.p8` private key file — **this can only be downloaded
   once**, so save it somewhere safe immediately.

### 5. `ASC_KEY_ID`
The Key ID from step 3.

### 6. `ASC_ISSUER_ID`
The Issuer ID from step 3 (shown at the top of the API Keys page, shared
across all your keys).

### 7. `ASC_KEY_CONTENT`
The `.p8` file, base64-encoded:
```bash
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
```
Paste the copied text as the secret value.

---

## Firebase App Distribution secrets (2)

### 8. `FIREBASE_APP_ID_ANDROID`
The Android app's Firebase App ID.
- Firebase Console → your project → ⚙️ **Project settings** → scroll to
  **Your apps** → select the Android app → copy the **App ID** (format:
  `1:1234567890:android:abcdef1234567890`).

### 9. `FIREBASE_SERVICE_ACCOUNT`
A service account JSON key with App Distribution access.
1. Firebase Console → ⚙️ **Project settings** → **Service accounts** tab.
2. Click **Generate new private key** → confirm → a `.json` file downloads.
3. Open that file, copy its **entire raw JSON content**, and paste it
   directly as the secret value (not base64-encoded — the workflow passes
   it straight to `serviceCredentialsFileContent`).

### Optional: `FIREBASE_TESTERS`
A comma-separated list of tester emails to notify on each distribution
(e.g. `alice@example.com,bob@example.com`). Already referenced by the
workflow; skip it if you'll manage testers manually in the Firebase Console
instead.

---

## Verifying it worked

Once all secrets are added, push to `claude/triverse-development-r2e05a` (or
merge to `main` for the TestFlight job, which only runs on `main`) and watch
the **Actions** tab:
- `Build iOS IPA` should get past the "No development certificates
  available" failure and produce a signed `.ipa`.
- `Deploy to Firebase App Distribution` should authenticate successfully
  instead of failing on `firebase login`.
- `Deploy to TestFlight` (main branch only) should upload the build and
  finish with a link to App Store Connect.

If a step still fails, the error message will point at which secret is
missing or malformed — `security import` failures usually mean the `.p12`
wasn't base64-encoded correctly (re-run the `base64 -i` command and make
sure no extra whitespace was pasted into the secret).
