# EddyScout — CI/CD Governance

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > this file.
>
> **AI agents:** Read and follow this file when creating or modifying GitHub Actions workflows; when adding, removing, or changing CI checks; when configuring build matrices; when managing secrets; or when setting up deployment pipelines.

---

## CI Platform

**GitHub Actions** is the sole CI/CD platform. All automated checks, builds, and deployments run as GitHub Actions workflows in `.github/workflows/`.

## Required CI Checks

Every pull request must pass the following checks before merge:

| Check | Command | Blocking | Purpose |
|-------|---------|----------|---------|
| **Format** | `dart format --set-exit-if-changed .` | Yes | Enforce consistent code style |
| **Analyze** | `flutter analyze --fatal-infos` | Yes | Static analysis with zero warnings |
| **Custom lint** | `dart run custom_lint` | Yes | Project-specific lint rules |
| **Codegen drift** | `build_runner build` + `git diff --exit-code` | Yes | Ensure generated files are up to date |
| **Test** | `flutter test` (all packages) | Yes | Unit and widget tests pass |
| **Integration Test** | `flutter test integration_test/` on Linux desktop (`xvfb-run`, `-d linux`) | Yes | App token gate + map → launch detail journey |
| **Coverage** | Coverage threshold check | No | Track coverage trends; do not gate on arbitrary % |

### Blocking vs. Non-Blocking

- **Blocking checks** must pass for a PR to be mergeable. Configure these as required status checks in GitHub branch protection.
- **Non-blocking checks** run and report but do not prevent merge. Use these for aspirational metrics (coverage trends, bundle size tracking).

## Build Matrix

| Dimension | Values |
|-----------|--------|
| **OS** | `ubuntu-latest`, `macos-latest` |
| **Flutter version** | Pinned via `.tool-versions` (see below) |

- Ubuntu covers analysis, formatting, tests, and codegen drift.
- macOS covers iOS builds and any macOS-specific tests.
- Use matrix strategy to run checks in parallel where possible.

## Flutter Version Pinning

Flutter and Dart versions are pinned via **`.tool-versions`** (asdf/mise format):

```
flutter <version>
```

- CI must install Flutter from this pinned version — do not use `stable` or `latest` channel references in workflows.
- Update `.tool-versions` in a dedicated PR when upgrading Flutter; include changelog review and platform testing.

## Workflow Structure

Organize workflows by concern:

```
.github/workflows/
├── ci.yml            # Format, analyze, lint, test, codegen drift
├── build-android.yml # Android APK/AAB build (on release tags)
├── build-ios.yml     # iOS IPA build (on release tags)
└── deploy.yml        # Deployment pipeline (future)
```

- Use reusable workflows or composite actions for shared steps (Flutter setup, caching).
- Cache `pub` dependencies and Flutter SDK between runs.

### Integration Test job (`ci.yml`)

The **Integration Test** job runs on `ubuntu-latest` with a virtual framebuffer:

1. Install Linux **desktop** build deps (`libgtk-3-dev`, `clang`, `cmake`, `ninja-build`, `pkg-config`, etc.) plus `xvfb` and `libglu1-mesa`. `-d linux` compiles the Flutter Linux embedder; unit-test `melos exec flutter test` in preflight does not.
2. **Token gate** — `flutter test integration_test/app_navigation_test.dart -d linux` (no extra dart-defines).
3. **Map → launch detail** — same device target with:
   - `--dart-define=MAPBOX_ACCESS_TOKEN=pk.integration_test`
   - `--dart-define=INTEGRATION_MAP_STUB=true`

Add **Integration Test** to GitHub branch protection required checks alongside Format, Analyze, Test, etc.

Local equivalent: `make integration-test` (uses `macos` on Darwin, `linux` on Linux).

## Secrets Management

| Secret | Scope | Notes |
|--------|-------|-------|
| **`MAPBOX_ACCESS_TOKEN`** | Build-time | Injected via `--dart-define` |
| **Firebase service account** | Deployment | Used by `firebase deploy` |
| **App signing keys** | Release builds | Android keystore, iOS provisioning |
| **API keys** | Build-time / runtime | Never hardcode; always inject via secrets |

Rules:
- Store all secrets in **GitHub Actions secrets** (repository or environment level).
- Never commit secrets, tokens, or keys to the repository.
- Use **environment-scoped secrets** for production vs. staging separation.
- Rotate secrets on a quarterly basis or immediately if compromised.

## Fastlane for Mobile Deployment (Future)

- **Fastlane** is the planned tool for automated mobile builds and app store submissions.
- `Fastfile` configurations will live in `apps/eddyscout/android/fastlane/` and `apps/eddyscout/ios/fastlane/`.
- Integrate fastlane lanes as GitHub Actions steps in the deployment workflow.
- Use `match` for iOS code signing management.

## Release Workflow

Releases follow the melos versioning flow:

1. **Version bump** — `melos version` with conventional commits to auto-determine bump level.
2. **Changelog** — Auto-generated from conventional commit messages.
3. **Tag** — Git tag created by melos (`v<version>`).
4. **CI build** — Release workflow triggers on version tags.
5. **Artifacts** — APK, AAB, and/or IPA uploaded as GitHub release assets.
6. **Deployment** — App store submission (future, via fastlane).

See `RELEASES.md` for the full release checklist and rollback procedures.

## Artifact Handling

- **Debug builds** are not archived in CI — they are ephemeral.
- **Release builds** are uploaded as workflow artifacts with a 90-day retention.
- **APK / AAB / IPA** are attached to GitHub Releases on tagged versions.
- Use artifact naming that includes version, build number, and platform: `eddyscout-<version>-<platform>.<ext>`.
