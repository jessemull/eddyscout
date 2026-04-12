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

## Runtime

This repo targets **Node.js 22** (`firebase.json` `runtime` + `package.json` `engines`). Local `npm` can use Node 22+ when developing functions.

## Callable still returns `UNAUTHENTICATED` (fingerprints already added)

Gen-2 Callables run on **Cloud Run**. The service must allow **unauthenticated invokers at the IAM layer** (`invoker: "public"` in `onCall` options) so the HTTPS request can reach Firebase’s Callable handler. That is **not** the same as skipping Firebase Auth: the handler still receives `request.auth` only when the client sends a valid Firebase ID token.

This repo sets `invoker: "public"` on both Callables. After changing it, redeploy:

`firebase deploy --only functions`

### Debug: no log line in Cloud Logging

Handlers log **`summarizeConditions invoked`** / **`submitConditionReport invoked`** at the very start (before the auth check). In [Cloud Logging](https://console.cloud.google.com/logs) for the project, filter on that text.

| What you see | Meaning |
|--------------|---------|
| **No** `summarizeConditions invoked` | The HTTPS request never reached the function handler. Fix **Cloud Run IAM** on the underlying service in **`us-west2`**: grant **`allUsers`** → **`Cloud Run Invoker`** (`roles/run.invoker`). List services with `gcloud run services list --region=us-west2`, then `gcloud run services add-iam-policy-binding SERVICE_NAME --region=us-west2 --member=allUsers --role=roles/run.invoker`. |
| Log shows **`hasAuth: false`** | The Callable reached your code but **Firebase did not attach `request.auth`**. Common causes: **App Check** enforcement without a registered debug provider, wrong **Firebase project** / **region** on the client, or emulator / Play Services issues. Try a **physical device**; in debug builds watch Flutter log lines prefixed with **`[Callable]`**. |
| Log shows **`hasAuth: true`** | Auth is fine; any failure is later in validation or the Anthropic call. |

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
