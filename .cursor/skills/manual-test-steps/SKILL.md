---
name: manual-test-steps
description: >-
  Produce concrete manual UI/UX test steps for emulator or device after
  feature work. Use when finishing a feature or bug fix, before opening a
  PR, when the user asks for manual test cases, QA steps, or a test plan
  for human verification.
---

# Manual Test Steps

Read before writing manual test instructions:

- `AGENTS.md` — `make dev`, `make run`, integration-test targets
- `docs/TESTING.md` — what automated tests already cover (do not duplicate)
- `docs/UI.md` — loading/error/empty state expectations
- `docs/ACCESSIBILITY.md` — when changes affect touch targets, text scale, or semantics
- `docs/PLATFORMS.md` — platform-specific behavior

Companion skills:
- `testing` — automated test strategy and coverage
- `responsive-ui-validation` — breakpoint and text-scale checks
- `accessibility-review` — a11y-specific manual checks
- `push-validation` — gate before push/PR

---

# When to Use

Use this skill when:

- an agent finishes UI, navigation, or UX work
- the user asks for manual QA, test cases, or a test plan
- opening a PR that needs human verification on device/emulator
- automated tests exist but real-device behavior must be confirmed (map, gestures, platform gates)

Do **not** use for pure domain/data refactors with no user-visible change — say so briefly instead.

---

# Core Principles

## Manual steps complement automation

- List what **humans must verify** that unit/widget/integration tests cannot fully cover.
- Do not restate `make test` or CI jobs unless a specific automated test should be run first as setup.

## Concrete and actionable

Each step must say **where to go**, **what to do**, and **what to expect**.

- GOOD: `Tap "Salmon Bay" marker → Launch detail opens with tide card visible`
- BAD: `Verify launch detail works`

## Organized, not verbose

- Group by **test case** (user goal), not by file changed.
- 3–8 steps per happy-path case; 1–3 steps per edge case.
- Skip obvious boilerplate unless this change affects it (e.g. skip full app cold-start if unchanged).

## Scope to the diff

- Every test case ties to something introduced or modified in the branch.
- Include regression spot-checks only when adjacent surfaces could break.

---

# Workflow

1. **Review the change** — files, routes, providers, strings, platform manifests.
2. **Identify surfaces** — screens, dialogs, navigation paths, map interactions, gates (Mapbox token, web redirect).
3. **Note automation** — one line on what widget/integration tests already cover.
4. **Draft test cases** — happy path first, then edge/error/degraded cases.
5. **Add environment block** — how to run the app for this verification.
6. **Output** using the template below in the agent's final message or PR test plan.

---

# Environment Setup

Default local run (Android emulator):

```bash
make dev
# or, if already bootstrapped:
make run ARGS="-d emulator-5554"
```

Prerequisites to mention when relevant:

| Requirement | When |
|-------------|------|
| `apps/eddyscout/.local.env` with `MAPBOX_ACCESS_TOKEN` | Map screen, launch detail with map |
| Light + dark theme | Any UI change |
| Portrait + landscape | Layout/navigation changes |
| Large text (Settings → Display → font size) | Copy, forms, overflow fixes |
| Offline / airplane mode | Error, retry, cached-data UX |

---

# Test Case Categories

Include only categories that apply to the change:

| Category | Edge cases to consider |
|----------|----------------------|
| **Navigation** | Back stack, deep link, unknown route/id, web-only gate |
| **Loading / error / empty** | Slow network, failed fetch, retry tap, stale cache indicator |
| **Forms / input** | Empty submit, invalid input, keyboard dismiss, rotation mid-edit |
| **Map / native** | Pinch/zoom, marker tap, stub vs real Mapbox, permission denied |
| **State persistence** | Kill app and relaunch, theme/skill preference retained |
| **Accessibility** | TalkBack/VoiceOver label on new controls, 2× text scale without overflow |

---

# Output Template

Copy and fill in for the user. Omit empty sections.

```markdown
## Manual test plan — [brief change title]

**Scope:** [1 sentence on what changed]

**Automated coverage:** [e.g. widget tests for LaunchDetailScreen loading/error — manual run still needed for map marker tap]

### Setup

1. [Device/emulator, env vars, `make dev` or `make run`, any dart-defines]

### TC-1: [Happy path — primary user goal]

**Preconditions:** [e.g. logged in, token configured, on map screen]

| Step | Action | Expected result |
|------|--------|-----------------|
| 1 | … | … |
| 2 | … | … |

### TC-2: [Edge case — short name]

| Step | Action | Expected result |
|------|--------|-----------------|
| 1 | … | … |

### TC-3: [Error / degraded — short name]

| Step | Action | Expected result |
|------|--------|-----------------|
| 1 | … | … |

### Regression (if applicable)

- [ ] [One-line spot-check on unrelated critical path]

### Not tested manually

- [What was skipped and why — e.g. iOS device not available; covered by integration_test]
```

---

# EddyScout-Specific Surfaces

Reference when the change touches these flows:

| Surface | Manual focus |
|---------|----------------|
| Mapbox token gate | App without token → gate screen; with token → map loads |
| Map → launch detail | Marker tap → detail route; back returns to map |
| Launch detail | Conditions loading skeleton → data; error + retry; go/no-go card |
| Web platform | Desktop browser width; web redirect if applicable |
| Unknown launch id | Navigate to invalid id → not-found screen, no crash |

---

# Example (abbreviated)

**Scope:** Add retry button on launch detail error state.

**Automated coverage:** Widget test asserts retry button visible on `AsyncError`.

### Setup

1. `make run ARGS="-d emulator-5554"` with valid `MAPBOX_ACCESS_TOKEN` in `.local.env`.
2. Enable airplane mode after map loads (or use dev-only network override if documented).

### TC-1: Retry recovers from error

| Step | Action | Expected result |
|------|--------|-----------------|
| 1 | Open any launch from map | Detail screen shows conditions |
| 2 | Enable airplane mode; pull to refresh or re-open detail | Error state with message (not raw exception) |
| 3 | Tap **Retry** | Loading indicator, then error remains while offline |
| 4 | Disable airplane mode; tap **Retry** | Conditions load; go/no-go card visible |

### TC-2: Dark mode

| Step | Action | Expected result |
|------|--------|-----------------|
| 1 | System dark mode → repeat TC-1 step 2 | Error colors readable; retry button meets contrast |

---

# Validation Checklist (author)

Before delivering the plan:

- [ ] Every test case maps to a change in the branch
- [ ] Steps name concrete UI labels, routes, or gestures
- [ ] Edge/error cases included where the code handles them
- [ ] Setup block is sufficient for a reviewer without chat context
- [ ] No duplicate of automated test assertions phrased as manual steps
- [ ] Plan fits on one screenful where possible (roughly ≤6 test cases)

---

# Output Expectations

Deliver the filled **Output Template** in the final response when finishing work, unless the user opts out.

Keep prose outside the template minimal: one sentence on how to run setup, then the template.
