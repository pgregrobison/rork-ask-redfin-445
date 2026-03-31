# Fix App Store submission by resetting signing credentials

The "Error Downloading App Information" error happens when the build system can't communicate properly with App Store Connect during the export/signing step. Since retrying hasn't helped, we need to reset the signing credentials.

**What I'll do:**

1. **Check current certificates and provisioning profiles** — List all existing distribution certificates and profiles in your Apple Developer account to identify stale or conflicting ones
2. **Delete conflicting provisioning profiles** — Remove any duplicate or outdated profiles for your app's bundle ID that may be causing the mismatch
3. **Regenerate the certificate** — Use the `ensureCertificate` tool to create a fresh distribution certificate
4. **Re-sync capabilities** — Make sure your app's entitlements match what's registered in the Apple Developer Portal
5. **Re-submit the build** — Attempt the App Store submission again with fresh credentials

This does **not** change any of your app's code — it only resets the signing/provisioning configuration on the Apple side.