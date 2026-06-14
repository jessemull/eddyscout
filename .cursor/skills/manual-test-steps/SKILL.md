---
name: manual-test-steps
description: >-
  Produce concrete, risk-based manual UI/UX test steps for emulator or
  device after feature work. Use when finishing a feature or bug fix, before
  opening a PR, when the user asks for manual test cases, QA steps, or a
  test plan for human verification.
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

---

# Change Analysis (Required)

Before writing test cases, summarize:

| Field | Content |
|-------|---------|
| **User-visible changes** | Screens, widgets, copy, gestures affected |
| **Routes affected** | New/changed go_router paths or redirects |
| **State/providers affected** | Providers, notifiers, async transitions touched |
| **Platform integrations** | Mapbox, permissions, native views, web gates |
| **Existing automated coverage** | Relevant unit/widget/integration tests |

**If no user-visible behavior changed**, respond with only:

> No manual testing required. Change is internal-only and covered by existing automated tests.

Do not generate a test plan for refactors, codegen-only updates, or test-only changes unless the user explicitly asks.

---

# Prioritization Rules

Generate test cases in this order — **stop when risk is covered**; do not pad the plan.

1. **What changed**
   - New functionality
   - Modified workflows
   - New state transitions
   - New navigation paths
2. **What could break**
   - Existing functionality sharing the same state/provider
   - Adjacent screens
   - Platform integrations
   - Persistence/caching
3. **Only then consider** (include only when the change could reasonably affect them)
   - Dark mode
   - Landscape
   - Large text
   - Accessibility
   - Offline

Do **not** generate boilerplate dark mode, landscape, accessibility, or offline tests for unrelated changes (e.g. a copy tweak does not need TC-2 Dark Mode).

---

# Test Case Priority

Assign **one priority per test case**. Focus manual effort on P0/P1 first; reviewers may skip P3 when time is limited.

| Priority | When to use |
|----------|-------------|
| **P0** | Crash, navigation failure, data loss, blocked primary journey |
| **P1** | Primary workflow for this change |
| **P2** | Secondary workflow, adjacent regression |
| **P3** | Cosmetic, polish, low-risk visual checks |

Label each test case: `TC-1 (P1): …`

---

# Core Principles

## Manual steps complement automation

- List what **humans must verify** that unit/widget/integration tests cannot fully cover.
- Do not restate `make test` or CI jobs unless a specific automated test should be run first as setup.

## Concrete and actionable

Each step must say **where to go**, **what to do**, and **what to expect**.

- GOOD: `Tap "Salmon Bay" marker → Launch detail opens with tide card visible`
- BAD: `Verify launch detail works`

## Expected result rules

Expected results must be **observable** — a reviewer can confirm pass/fail without judgment calls.

| Good | Bad |
|------|-----|
| Launch detail title displays "Salmon Bay" | Works correctly |
| Retry button is disabled while request is in progress | Looks good |
| Back returns to map with prior camera position | Loads successfully |
| Snackbar shows "Unable to load conditions" | No issues observed |

## Organized, not verbose

- Group by **test case** (user goal or risk), not by file changed.
- 3–8 steps per P0/P1 case; 1–3 steps per P2 edge case.
- Roughly ≤6 test cases total unless the change is large.

## Traceability required

Every user-visible change must map to at least one test case in the **Traceability Matrix**. If a change cannot be mapped, explain why in the matrix.

---

# Flutter State Transition Checks

When the change touches async UI, providers, or navigation, include applicable transitions (many Flutter bugs live here, not on the happy path):

- Loading → Success
- Loading → Error
- Error → Retry → Success
- Empty → Data appears
- Background → Foreground (app resumed mid-request)
- Rotation during async operation
- Kill app → Relaunch (persistence)
- Back navigation after async completion

Only add transitions **relevant to the diff** — do not list all eight for every change.

---

# Workflow

1. **Change Analysis** — required summary; exit early if internal-only.
2. **Prioritize risks** — what changed, what could break (see Prioritization Rules).
3. **Draft traceability matrix** — map each changed surface to a TC (or justify omission).
4. **Write test cases** — P0/P1 first; observable expected results; Flutter transitions where applicable.
5. **Add setup** — how to run the app for this verification.
6. **Output** using the template below.

---

# Environment Setup

Default local run (Android emulator):

```bash
make dev
# or, if already bootstrapped:
make run ARGS="-d emulator-5554"
```

Prerequisites — mention **only when the change requires them**:

| Requirement | When |
|-------------|------|
| `apps/eddyscout/.local.env` with `MAPBOX_ACCESS_TOKEN` | Map screen, launch detail with map |
| Light + dark theme | Theme/color/token changes |
| Portrait + landscape | Layout or navigation changes |
| Large text (Settings → Display → font size) | Copy, forms, overflow fixes |
| Offline / airplane mode | Error, retry, cached-data UX |

---

# Test Case Categories

Include only categories that apply per Prioritization Rules:

| Category | Edge cases to consider |
|----------|----------------------|
| **Navigation** | Back stack, deep link, unknown route/id, web-only gate |
| **Loading / error / empty** | Slow network, failed fetch, retry tap, stale cache indicator |
| **Forms / input** | Empty submit, invalid input, keyboard dismiss, rotation mid-edit |
| **Map / native** | Pinch/zoom, marker tap, stub vs real Mapbox, permission denied |
| **State persistence** | Kill app and relaunch, preference retained |
| **Accessibility** | TalkBack/VoiceOver on new controls, 2× text scale without overflow |

---

# Output Template

Copy and fill in for the user. Omit empty sections.

```markdown
## Manual test plan — [brief change title]

### Change analysis

| Field | Summary |
|-------|---------|
| User-visible changes | … |
| Routes affected | … |
| State/providers affected | … |
| Platform integrations | … |
| Existing automated coverage | … |

### Traceability matrix

| Changed surface | Covered by | Priority |
|-----------------|------------|----------|
| … | TC-1 | P1 |
| … | TC-2 | P2 |

### Setup

1. [Device/emulator, env vars, `make dev` or `make run`, any dart-defines]

### TC-1 (P1): [Primary workflow — short name]

**Preconditions:** …

| Step | Action | Expected result |
|------|--------|-----------------|
| 1 | … | … |

### TC-2 (P2): [Risk or edge case — short name]

| Step | Action | Expected result |
|------|--------|-----------------|
| 1 | … | … |

### Regression (if applicable)

- [ ] [Adjacent surface that shares state/provider — one line]

### Not tested manually

- [What was skipped and why]
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

**Change analysis:** Retry button added to launch detail `AsyncError` state; `launchDetailProvider` refetch on tap. Routes unchanged. Widget test covers error UI visibility.

**Traceability matrix:**

| Changed surface | Covered by | Priority |
|-----------------|------------|----------|
| Retry button + refetch | TC-1 | P1 |
| Loading → Error → Retry → Success | TC-1 | P1 |
| Retry disabled while in-flight | TC-2 | P2 |

### Setup

1. `make run ARGS="-d emulator-5554"` with valid `MAPBOX_ACCESS_TOKEN` in `.local.env`.

### TC-1 (P1): Retry recovers from error

| Step | Action | Expected result |
|------|--------|-----------------|
| 1 | Open any launch from map | Detail title matches launch name; conditions load |
| 2 | Enable airplane mode; re-open same launch | Error message visible; **Retry** button visible (not raw exception text) |
| 3 | Tap **Retry** while offline | Loading indicator appears; error state remains |
| 4 | Disable airplane mode; tap **Retry** | Loading indicator appears; conditions and go/no-go card display |

### TC-2 (P2): Retry disabled during request

| Step | Action | Expected result |
|------|--------|-----------------|
| 1 | On error state, tap **Retry** twice quickly | Button disabled or second tap ignored until first request completes |

*(No dark-mode TC — this change did not touch theme tokens or colors.)*

---

# Validation Checklist (author)

Before delivering the plan:

- [ ] Change analysis completed; early exit used if internal-only
- [ ] Traceability matrix covers every user-visible change
- [ ] P0/P1 cases address what changed and what could break
- [ ] No boilerplate dark mode / offline / a11y cases unless justified
- [ ] Expected results are observable, not subjective
- [ ] Flutter state transitions included only where the diff touches async UI
- [ ] Setup block is sufficient for a reviewer without chat context

---

# Output Expectations

Deliver the filled **Output Template** in the final response when finishing UI/UX work, unless the user opts out.

For internal-only changes, deliver only the one-line no-manual-testing response.

Keep prose outside the template minimal.
