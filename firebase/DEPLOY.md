# Deploying Cloud Functions

## “Build service account missing permissions”

If deploy fails with:

`Could not build the function due to a missing permission on the build service account`

Google’s [troubleshooting guide](https://cloud.google.com/functions/docs/troubleshooting#build-service-account) recommends granting the default **Compute Engine** service account the **Cloud Build Builder** role.

### Google Cloud Console (no `gcloud` required)

1. Open [IAM & Admin → IAM](https://console.cloud.google.com/iam-admin/iam) for your Firebase/GCP project.
2. Find the principal ending in **`...@developer.gserviceaccount.com`** (name is often **Default compute service account**). The full email looks like `PROJECT_NUMBER-compute@developer.gserviceaccount.com`.
3. Click **Edit** (pencil) → **Add another role**.
4. Add **Cloud Build Builder** (`roles/cloudbuild.builds.builder`).
5. Save, wait a minute, then run `firebase deploy --only functions` again.

If it still fails, open the **Cloud Build** log link from the error and check for **Artifact Registry** or **Storage** denials; you may need to grant **`...@cloudbuild.gserviceaccount.com`** roles such as **Artifact Registry Writer** and **Logs Writer** on the same IAM page.

### Optional: `gcloud` (replace `PROJECT_ID` and `PROJECT_NUMBER`)

```bash
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
  --role="roles/cloudbuild.builds.builder"
```

`PROJECT_NUMBER` appears in the Firebase/GCP console (Project settings) and in deploy logs (e.g. `953765797626-compute@developer...`).

## Firestore indexes (`listConditionReports`)

The Callable `listConditionReports` queries `conditionReports` by `launchId` and `createdAt`. Deploy the composite index after pulling changes:

```bash
firebase deploy --only firestore:indexes
```

If you deploy functions before indexes finish building, the first list call may fail until the index is ready (the Firebase console shows index status and offers a direct link if a query error mentions a missing index).

## Runtime

This repo targets **Node.js 22** (`firebase.json` `runtime` + `package.json` `engines`). Local `npm` can use Node 22+ when developing functions.

## Callable still returns `UNAUTHENTICATED` (fingerprints already added)

Gen-2 Callables run on **Cloud Run**. The service must allow **unauthenticated invokers at the IAM layer** (`invoker: "public"` in `onCall` options) so the HTTPS request can reach Firebase’s Callable handler. That is **not** the same as skipping Firebase Auth: the handler still receives `request.auth` only when the client sends a valid Firebase ID token.

This repo sets `invoker: "public"` on both Callables. After changing it, redeploy:

`firebase deploy --only functions`

### Reading Cloud Run logs

In [Cloud Logging](https://console.cloud.google.com/logs), filter on the Cloud Run service (e.g. **`summarizeconditions`**) and log **`run.googleapis.com/requests`** or **`run.googleapis.com/stderr`**.

| What you see | Meaning |
|--------------|---------|
| **401** on `POST` to the `…cloudfunctions.net/summarizeConditions` URL | Request blocked at **Cloud Run IAM**. Grant **`allUsers`** → **Cloud Run Invoker** on the service in **`us-west2`**, or redeploy after `invoker: "public"` is set. |
| **401** / `unauthenticated` in the app but **200** on the HTTP request | Firebase rejected the **Callable auth** context (token / App Check / project mismatch). |
| **500** and **`run.googleapis.com/stderr`** shows an **Anthropic** error | API key, org billing/credits, or model access — not fingerprints or Cloud Run invoker. |

## Android: `cloud_functions` / `UNAUTHENTICATED` even though Auth shows a user

Your `google-services.json` may list `"oauth_client": []` until you register the app’s **SHA certificate fingerprints**.

1. Debug keystore (typical local `flutter run`):

   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey \
     -storepass android -keypass android
   ```

2. [Firebase Console](https://console.firebase.google.com) → Project **settings** (gear) → **Your apps** → Android `com.eddyscout.eddyscout` → **Add fingerprint** → paste **SHA-1** and **SHA-256**.

3. Download the **updated** `google-services.json` and replace `android/app/google-services.json` (it should gain non-empty `oauth_client` entries when OAuth clients are created).

4. **Stop the app** and `make run` again.

Without this, **Anonymous** sign-in can still appear to work in logs while **Callable** requests fail with `UNAUTHENTICATED`.

### Emulator log noise (`Unknown calling package name 'com.google.android.gms'`, `DEVELOPER_ERROR`)

Often harmless on **AVDs** with incomplete Google Play Services. Prefer a **Google Play** system image, update **Google Play services** on the emulator, or test on a **physical device**. `GFXSTREAM` GL errors are common on emulators using the **Mapbox** map.

## Flutter: `[firebase_auth/admin-restricted-operation]`

If the app shows this after `signInAnonymously()`, Firebase Auth is refusing the operation—**not** Cloud IAM and **not** the Anthropic key.

1. [Firebase Console](https://console.firebase.google.com) → your project → **Authentication** → **Sign-in method** → enable **Anonymous** → **Save**.
2. **Authentication** → **Settings** (gear) → **User actions** — if there is an option to block new sign-ups, ensure anonymous / account creation is allowed for your use case.
3. Stop the app completely and run **`make run` again** (hot reload does not re-run `main()`).

If **App Check** is enforced for Authentication, register a debug provider for development or temporarily turn enforcement off until the app is registered.
