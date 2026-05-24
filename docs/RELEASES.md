# EddyScout — Release Governance

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > this file.
>
> **AI agents:** Read and follow this file when preparing a release; when bumping versions; when creating release branches or tags; when generating changelogs; when managing rollbacks; or when discussing app store submissions.

---

## Semantic Versioning

All packages and the app follow **semver** (`MAJOR.MINOR.PATCH`):

| Bump | When |
|------|------|
| **MAJOR** | Breaking changes to public APIs or user-facing behavior that requires migration |
| **MINOR** | New features, non-breaking enhancements |
| **PATCH** | Bug fixes, performance improvements, documentation |

The Flutter app additionally uses a **build number** (`version: X.Y.Z+buildNumber`) that increments with every release build, regardless of version bump level.

## Release Branch Strategy

```
main ─────────────────────────────────────────────►
       \                          \
        release/1.2.0              release/1.3.0
```

- **`main`** is the development trunk. All PRs merge here.
- **`release/<version>`** branches are cut from `main` when preparing a release.
- Only **bug fixes and release-critical patches** are cherry-picked onto release branches.
- After release, the branch is **tagged** (`v<version>`) and may be deleted once merged back to `main`.
- Hotfixes branch from the release tag, not from `main`.

## Changelog Generation

Changelogs are generated automatically using **melos version** with **conventional commits**:

```bash
melos version --yes
```

- Commit messages must follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.
- Melos parses commit prefixes (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, `perf:`, `ci:`) to categorize changelog entries.
- The generated `CHANGELOG.md` is committed as part of the version bump PR.
- Review the generated changelog for clarity before merging — edit only for readability, not to add or remove entries.

### Conventional Commit Examples

```
feat: add launch detail share button
fix: correct tide display for coastal launches
chore: update dependency versions
docs: add platform governance documentation
refactor: extract conditions service interface
test: add widget tests for go/no-go card
perf: lazy-load launch images on map
ci: add codegen drift check to CI pipeline
```

## Release Checklist

Before every release:

- [ ] All CI checks pass on the release branch
- [ ] Manual smoke test on Android device/emulator
- [ ] Manual smoke test on iOS device/simulator
- [ ] Web smoke test (if secondary platform is active)
- [ ] Changelog reviewed and accurate
- [ ] Version bumped via `melos version`
- [ ] No `TODO` or `FIXME` items tagged for this release remain
- [ ] Release notes drafted for app store listing (if applicable)
- [ ] Privacy policy and terms of service are current
- [ ] All secrets and API keys are correctly configured for production
- [ ] Build artifacts generated and tested (APK/AAB/IPA)

## Rollback Procedures

### Immediate rollback (app store)

1. If a critical bug is discovered post-release, **halt the staged rollout** in the app store console.
2. Revert to the previous version by promoting the prior build or submitting a hotfix build.
3. Communicate the rollback internally; document the root cause.

### Code rollback

1. Identify the offending commit(s).
2. Create a revert commit on `main` (or the release branch for hotfixes).
3. **Do not** force-push or rewrite history on shared branches.
4. Cut a new patch release with the revert included.

### Data rollback

- If a release includes a database migration (Drift schema change), ensure the migration is **reversible** or has a documented manual rollback procedure.
- Test migration rollback as part of the release QA process.

## App Store Submission (Future)

### Google Play Store

- Build signed AAB via `flutter build appbundle --release`.
- Upload via fastlane or the Play Console.
- Use staged rollout (start at 10%, monitor crash rate, expand to 100%).
- Maintain a production and internal testing track.

### Apple App Store

- Build signed IPA via `flutter build ipa --release`.
- Upload via fastlane or Transporter.
- Submit for App Review; allow 24–48 hours for review.
- Use TestFlight for internal and external beta testing before production release.

## Beta / Staged Rollout Expectations

| Phase | Audience | Duration | Gate |
|-------|----------|----------|------|
| **Internal testing** | Team members | 1–2 days | Smoke test pass |
| **Closed beta** | Invited testers | 3–5 days | No P0/P1 bugs reported |
| **Staged rollout (10%)** | Production users | 2–3 days | Crash rate < 1%, no critical regressions |
| **Full rollout (100%)** | All users | — | Staged rollout gate passed |

- Monitor crash reporting dashboards actively during staged rollout.
- Pause rollout immediately if crash rate exceeds thresholds or critical user reports emerge.
