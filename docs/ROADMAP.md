# EddyScout — product roadmap

High-level feature map for a PNW-focused kayak companion: **decision-first**, **local nuance**, **conditions fusion**, **honest safety framing**, and **Flutter + Mapbox** on the client. This document is a living plan; tick or adjust as you ship.

> **Platform:** target architecture is **complete** (waves 1–3 merged; see § Platform architecture). **Product work** is Phase C+ below. New UI belongs in `packages/features/*/presentation/`, not `apps/eddyscout/lib/screens/`.
>
> **Last updated:** 2026-06-28

## Vision

EddyScout helps paddlers **discover where to go**, **understand river and weather context in one place**, and **decide if today makes sense** for their skill level—starting in the Portland / greater PNW area. It is not a replacement for judgment, training, or on-scout assessment.

## Product pillars

```mermaid
flowchart TB
  subgraph discover [Discover]
    map[Map_and_launches]
    filters[Skill_access_filters]
    similar[Similarity_embeddings]
  end
  subgraph decide [Decide]
    fuse[Conditions_fusion]
    gonogo[Go_NoGo_interpretation]
    windows[Time_windows]
  end
  subgraph assist [Assist_intelligence]
    digest[Snapshot_summary]
    chat[Chat_with_tools]
    safetyintel[Safety_intelligence]
    routecheck[Route_validation_feedback]
  end
  subgraph plan [Plan]
    routes[Route_planner]
    multiday[Multi_day_trips]
    export[GPX_export_import]
  end
  subgraph onwater [On_water]
    location[User_location_heading]
    offline[Offline_maps_optional]
  end
  subgraph community [Community]
    social[Social_trips_reports]
    auth[Authentication]
  end
  discover --> decide
  decide --> assist
  assist --> plan
  plan --> onwater
  community --> discover
```

| Pillar | Intent |
|--------|--------|
| **Discover** | Map, launches, filters (skill, access, hazards); optional **semantic “similar to”** via embeddings. |
| **Decide** | Fuse weather, wind, flow, tides where relevant; output Go / marginal / no-go + reasons (per launch today; **per route** planned). |
| **Assist (LLM)** | Summaries, Q&A, and coaching **grounded in fetched data + curated metadata**—not a replacement for judgment. |
| **Plan** | Routes, put-in / take-out, GPX; **multi-day** river descents and sea-kayak archipelago hops (daily legs, overnight stops). |
| **On-water** | Location, bearing, later drift-aware hints; optional offline. |
| **Community** | Trips, condition reports, finding paddlers—without unsafe defaults on live tracking. |

---

## Feature list (your themes + gaps)

| # | Feature | In-product meaning | Notes |
|---|---------|-------------------|--------|
| 1 | **Weather** | Temp, precip, clouds; NOAA or a focused weather API | Wind is a separate axis for paddlers; hyperlocal matters (Columbia, gorge). |
| 2 | **River conditions** | Wood, dam releases, “sketchy at this flow,” closures | Largely **not** in public APIs → crowdsourced + curated **local intelligence**. |
| 3 | **Wind** | Speed + **gusts**, direction; marine zones where relevant | Open water and fetch; tie to **segment exposure** over time. |
| 4 | **River flow / speed** | USGS cfs / gauge height; **gauge → launch or segment**, not one number per whole river | **Per-stretch** flow bands (min / optimal / max). |
| 5 | **Go / no-go** | Clear call + reasons + **marginal**; legal/UX **disclaimer** | Per-launch today (launch detail). Include cold water and skill; avoid false confidence. |
| — | **Route Go / No-Go** | Same deterministic verdict + reasons for a **planned route** (waypoints now; polyline segments later) | Roll up **worst** segment/waypoint; show **which part** triggered it; reuse launch evaluator + skill profile; same disclaimers—not a safety guarantee. |
| 6 | **Route planner** | Put-in / take-out, snap or align to water; later drift vs wind | Needs **river geometry** or curated segments. Route Go/No-Go depends on planner waypoints (Phase E). |
| — | **Multi-day trip planning** | Plan **multi-leg expeditions**: downriver trips with daily segments + overnight stops; **archipelago / island-hopping** sea-kayak routes with tide/current windows per day | Exploration → v1: **days** as first-class (not one long polyline only); per-day distance/time; conditions rollup per day; portage gaps between water bodies. |
| 7 | **Social** | Trip intent, post-trip reports (conditions, wildlife), find paddlers | Start with **planned trips + TTL**; moderation + privacy before heavy live location. |
| 8 | **Authentication** | Accounts, saved content, posts | Defer until social or saved routes need identity. |
| — | **Tides / currents** | Estuary, coastal, Sauvie-adjacent | NOAA tides/currents APIs. |
| — | **Cold water / safety UX** | Hypothermia / cold-shock awareness; education links | Persistent PNW-relevant messaging. |
| — | **User location + “which way”** | GPS, bearing to waypoint; later smarter drift hints | Core **on-water** value from early product discussions. |
| — | **Offline** | Cached tiles; optional last-known conditions | Mapbox offline + scoped geography. |
| — | **Alerts** | Flow or wind thresholds | Often pairs with subscriptions later. |
| — | **Trip log / GPX** | History, export, share | Complements routes and social. |
| — | **Access / permits / tribal** | Legality, seasonality, respect for restrictions | Static metadata + clear UI tags. |
| — | **Legal / attribution** | Mapbox, USGS, NOAA; liability copy | Ship early. |
| — | **Condition snapshot summary (LLM)** | Short narrative digest of the current **ConditionsSnapshot** + launch tags (exposure, tide relevance, river system) | **Grounded:** model input is structured JSON + timestamps; output is “planning copy,” not a safety guarantee. |
| — | **Conditions chat (LLM + tools)** | User asks questions; model calls **tools** to refresh or re-fetch NWS / USGS / tides / marine as needed | Tools = same provider layer as today (`ConditionsService` or successors); no browsing arbitrary web unless explicitly added later. |
| — | **Route validation / feedback (LLM)** | User describes or selects put-in / take-out (or future drawn route); model **comments on plausibility** vs curated segments, distance class, exposure—**not** turn-by-turn navigation | Start as “validation / sanity check” before full geometry-backed planner. |
| — | **Safety intelligence layer (LLM + rules)** | Cold water, skill fit, PFD/whistle/permits, when to bail—**templated canonical facts** + optional LLM phrasing; reinforce disclaimers | Must not contradict static safety copy; optional RAG over **your** editorial docs later—not open-ended medical advice. |
| — | **Embeddings & similarity search** | **“Similar launches”** / **similar routes** / similar trip reports by embedding a short **canonical text profile** per entity (name, river, exposure, notes, skill tags, distance class) | Feasible and common pattern: **vector DB** (e.g. pgvector, hosted vector index) or on-device for small corpora; combine with **filters** (distance, river system, skill) so results stay sensible. Rebuild or upsert vectors when curated data changes. |

**Hidden but critical:** **gauge–segment–launch data model** (which USGS site applies to which stretch)—this is foundational for items 4 and 5. **Embedding corpus** (what text you embed + version) is similarly foundational for trustworthy similarity.

---

## Execution order

| Step | Work | Status |
|------|------|--------|
| 1 | **Platform waves 1–3** — monorepo, `@riverpod`, Result boundaries, router package, feature `presentation/` layering, app-shell closeout | **Done** (#19–#36, closeout) |
| 2 | **Firebase dev / production environments** — `.firebaserc` aliases, client config selection, deploy runbook (§ Firebase environments) | **In progress** (projects configured in repo; wiring + deploy to both remain) |
| 3 | **Phase C+** — product slices in this file (GPX, saved routes, moderation QA, auth, two-pin catalog, …) | **Now** (Firebase-backed QA: pick project via alias; prefer **dev** once mirrored) |

---

## Data architecture & storage (today)

EddyScout **intentionally splits data by type**. Not everything belongs in Firebase; that is a product choice for a **curated regional guide**, not an oversight.

| Data | Where today | Role |
|------|-------------|------|
| **Launch catalog** (ids, names, access + water-entry coordinates, flow bands, tide/marine tags) | Dart source: `packages/core/lib/src/launch_catalog.dart` (`kLaunchPoints`) | Editorial truth — **ships with the app**; offline; PR-reviewed |
| **River / routing geometry** | Bundled assets: `apps/eddyscout/assets/hydro/*.geojson` | Offline routing; versioned in git + CI geometry gates |
| **Reachability / suggested trips** | Bundled JSON: `assets/data/launch_*_index.json` | Precomputed from hydro graph at build time |
| **Live conditions** (weather, USGS flow, tides, marine) | **External APIs** (NWS, USGS, NOAA) at runtime | Authoritative sources — not copied into our DB as source of truth |
| **Saved routes** | **Local device** (Drift / SQLite) | User-owned; private by default |
| **Preferences / skill profile** | **Local** (`SharedPreferences` via `KeyValueStore`) | Device-local settings |
| **Community condition reports** | **Firestore** `conditionReports` (Admin SDK + Callables only) | User-generated text; references launches by **`launchId`** |
| **Report moderation policy** | **Firestore** `config/moderation` | Admin UIDs, keywords, retention — **not map coordinates** |
| **AI digest / summary caches** | **Firestore** (`launchReportDigests`, `reportDigestRate`; admin-only reads) | Server-side Anthropic key; Callable responses to clients |

**How reports attach to the map:** Firestore stores `launchId` + message + moderation fields. The app resolves `launchId` → coordinates from **`kLaunchPoints`**, not from Firestore.

**Principles:**

- **Curated map truth** — bundled catalog + hydro assets; quality control via code review and release.
- **User-generated notes** — Firebase with auth, moderation, TTL; clients never write Firestore directly.
- **Live conditions** — fetch from agencies; show source + timestamp in UI.
- **Do not** store launch lat/lng as client-writable Firestore documents in the current design.

### Catalog distribution pipeline (deferred)

**Not prioritized yet** — document so we do not forget when launch churn or multi-region scale outgrows ship-with-app.

Today, adding or fixing a launch requires editing `launch_catalog.dart` (and often hydro indexes / reachability regen) and shipping an app release. That is acceptable for a small curated PNW catalog; it becomes painful when we want frequent pin fixes or many regions without store cycles.

**Future direction (pick one or hybrid when needed):**

| Approach | Idea |
|----------|------|
| **Build-time pipeline (minimal)** | Editorial YAML/JSON in repo → CI generates `launch_catalog.dart` + validates snaps → same release cadence, less hand-editing |
| **Remote catalog + bundled fallback** | Versioned catalog JSON on CDN or Firestore (read-only to clients); app loads remote when online, falls back to bundled copy when offline or fetch fails |
| **CMS → pipeline** | Human-friendly editor exports into the build-time or remote path above |

**Checklist (when prioritized — Phase D / ops):**

- [ ] **(Phase D / catalog)** Editorial source of truth — structured launch schema (access + water-entry coords, bands, tags); document ownership and review
- [ ] **(Phase D / catalog)** CI pipeline — source → generated catalog artifact(s); wire into `make gen` / preflight; regen reachability/suggested-trips hooks where coords change
- [ ] **(Phase D / catalog)** Optional remote distribution — semver’d catalog blob; client fetch + **bundled fallback**; never client-writable launch coordinates in Firestore
- [ ] **(Phase D / catalog)** Migration path — two-pin coordinate model + snap-quality gates before bulk catalog moves (see R3 items below)
- [ ] **(Phase D / catalog)** Ops runbook — pin fix without app release (remote path only); rollback; embedding/index invalidation when copy changes

Relates to **Launch contributions (v1)** below (crowd-sourced *suggestions*) — contributions must not bypass editorial merge into the catalog pipeline.

### Firebase environments (dev / production) — **configured in repo; wiring remaining**

**Status:** Two Firebase/GCP projects are **already configured** in `apps/eddyscout/.firebaserc`:

| Environment | Firebase / GCP project | `.firebaserc` alias | Intended use |
|-------------|------------------------|---------------------|--------------|
| **Development** | `eddyscout-dev` | `default` | Local `make run`, moderation QA, keyword holds, destructive tests, function iteration |
| **Production (MVP)** | `eddyscout-c29b9` | `mvp` | Store / TestFlight builds, real community data, moderated content users see |

Optional **staging** (`eddyscout-staging`) is out of scope for v1 unless release cadence needs it; CI can add it later per `docs/CI_CD.md`.

**Working directory:** All Firebase CLI commands and Node scripts (e.g. moderation seed) run from **`apps/eddyscout`**, not the monorepo root. Example:

```bash
cd apps/eddyscout
node firebase/scripts/seed_moderation_config.mjs --project eddyscout-c29b9
```

**Why wiring still matters:** Condition-report **moderation** (Phase C) is implemented but hard to QA safely if everyone hits prod by accident. `USE_FIREBASE=true` only toggles Firebase on/off — it does **not** select dev vs prod. Which backend you use is determined by **`google-services.json`** (symlinked via `make dev` / `make fetch-google-services`) and optional **`EDDYSCOUT_FIREBASE_ALIAS`** (`default` → dev, `mvp` → prod). Today helper scripts **default to `mvp` (prod)** unless you override the alias.

**Goal (remaining):** Document and enforce a default of **dev** for daily local work; deploy to **both** projects deliberately; never ship backend changes to prod without a dev smoke-test.

**Repo hooks (present — use them):**

| Piece | Location | Notes |
|-------|----------|-------|
| Firebase CLI aliases | `apps/eddyscout/.firebaserc` | `firebase use default` → dev; `firebase use mvp` → prod |
| Client project binding | `apps/eddyscout/android/app/google-services.json` (gitignored) | Whichever JSON is present wins; no Dart constant overrides project |
| Symlink helper | `scripts/ensure_android_secrets.sh`, `make fetch-google-services` | Canonical copy in `~/.config/eddyscout/`; **`EDDYSCOUT_FIREBASE_ALIAS`** (`default` \| `mvp`; scripts default **`mvp`**) |
| Feature gate | `USE_FIREBASE` in `.local.env` → `--dart-define` | See `apps/eddyscout/env.example`, `scripts/run_android.sh` |
| Bootstrap | `Firebase.initializeApp()` + anonymous auth | `apps/eddyscout/lib/bootstrap/app_bootstrap.dart` |
| Backend deploy docs | `apps/eddyscout/firebase/DEPLOY.md` | Indexes, functions, moderation order, Android SHA fingerprints |
| Moderation seed script | `apps/eddyscout/firebase/scripts/seed_moderation_config.mjs` | From `apps/eddyscout`: `--project eddyscout-dev` or `eddyscout-c29b9` |
| Function unit tests | `cd apps/eddyscout/firebase/functions && npm test` | No Firestore; safe offline |

**What is *not* built yet:**

- Documented **two** native config files (e.g. `google-services.dev.json` / `google-services.prod.json`) and how to select them for daily dev vs release builds
- Android **product flavors** (or equivalent) so `make run` defaults to dev without manual file swapping
- Deploy runbook: **always deploy to dev first**, smoke-test, then `firebase use mvp` + prod deploy
- Separate **Secret Manager** secrets per project (`ANTHROPIC_API_KEY`, future keys)
- `config/moderation` and indexes deployed to **both** projects with different `adminUids` / test keywords on dev
- CI policy: PRs never deploy to prod; tagged releases deploy prod only (`docs/CI_CD.md` environment-scoped secrets)
- Flutter **emulator** wiring (Firestore + Functions) — optional follow-up; not required if dev GCP project exists

**Recommended implementation (pick-up guide):**

1. **Console:** Confirm `eddyscout-dev` exists (or create). Register Android app `com.eddyscout.eddyscout` in **both** projects. Enable **Anonymous** sign-in on both. Add debug **SHA-1 / SHA-256** fingerprints on both (see `firebase/DEPLOY.md`).
2. **Secrets:** `firebase use default` then `firebase functions:secrets:set ANTHROPIC_API_KEY` on dev; repeat on `mvp` for prod (same or separate Anthropic key — separate is safer for rate limits).
3. **Deploy dev backend:** From `apps/eddyscout`: `firebase use default` → `firebase deploy --only firestore:rules,firestore:indexes` → wait for indexes → `node firebase/scripts/seed_moderation_config.mjs --project eddyscout-dev` → `firebase deploy --only functions`.
4. **Client config:** `make fetch-google-services` (after `firebase login`) writes `~/.config/eddyscout/google-services-<project>.json`; `make dev` symlinks into each worktree. Override with `EDDYSCOUT_FIREBASE_ALIAS` / `EDDYSCOUT_GOOGLE_SERVICES`. Document prod path for release builds only.
5. **Docs:** Extend `firebase/DEPLOY.md` with an **Environments** section (aliases, never deploy functions to prod without dev smoke-test). Update `env.example` / `CONTRIBUTING.md` with “local dev uses **dev** project”.
6. **Optional hardening:** Android `productFlavors` `dev` / `prod` with distinct `applicationIdSuffix` for side-by-side installs; iOS schemes when iOS Firebase ships.

**Interim:** Until dev is mirrored and local default flips to **`default`**, moderation QA may run against **`eddyscout-c29b9`** — accept test `conditionReports` in prod Firestore or restrict to function unit tests + one controlled device.

**Checklist (Phase C / infra):**

- [x] **(Infra / Firebase)** Configure **`.firebaserc`** — `default` → `eddyscout-dev`, `mvp` → `eddyscout-c29b9`
- [x] **(Infra / Firebase)** Moderation seed script + backend paths under **`apps/eddyscout/firebase/`**
- [ ] **(Infra / Firebase)** Confirm **both** GCP projects exist in Console; mirror Android app + Anonymous auth + SHA fingerprints on each
- [ ] **(Infra / Firebase)** Document and store **dev + prod** `google-services.json` paths; **default local dev to dev** (`EDDYSCOUT_FIREBASE_ALIAS=default` or flavor)
- [ ] **(Infra / Firebase)** Deploy rules, indexes, functions, and `config/moderation` to **dev**; smoke-test all Callables
- [ ] **(Infra / Firebase)** Deploy runbook in `firebase/DEPLOY.md` — `firebase use default` vs `mvp`, order of operations, per-project secrets
- [ ] **(Infra / Firebase)** Prod deploy checklist — explicit `firebase use mvp` + human confirmation before functions/indexes hit `eddyscout-c29b9`
- [ ] **(Infra / Firebase)** CI / release policy — no prod Firebase deploy from PR CI; prod on tag or manual workflow (align with `docs/CI_CD.md`)
- [ ] **(Infra / Firebase)** Re-run moderation manual QA on **dev** after env split (submit, keyword hold, moderator queue, approve/reject, approved-only list)

Relates to **§ Data architecture** (Firestore UGC), **(Reports / mod)** moderation (shipped), and **Integration test backlog** (report submit journey after env is stable).

### Content moderation automation (Phase D)

**Shipped (Phase C):** keyword **hold** (not auto-reject), human approve/reject queue, TTL, approved-only reads, moderator ACLs. Default posture is **auto-approve** unless a configured keyword matches — adequate for plumbing and low-volume QA, **not** production-grade trust & safety alone.

**Goal (Phase D):** Layer **policy + automation + metrics** on the existing `moderationStatus` model (`approved` | `held` | `rejected`) in `submitConditionReport` — no client writes; scores/reasons stored server-side for audit.

#### Free / low-cost options (verify pricing pages before ship — tiers change)

| Option | Free tier? | Rough paid | Notes for EddyScout |
|--------|------------|------------|---------------------|
| **Keyword + regex hold** (shipped) | Free (self) | — | Fast, brittle; good for test hooks + obvious spam; false positives on paddling vocabulary (“dam”, “kill switch”, etc.) |
| **Domain allowlist / denylist** (repo) | Free (self) | — | Pairs with keywords; document PNW paddling terms that must not auto-hold |
| **OpenAI Moderation API** (`omni-moderation-latest`) | **Free** (per OpenAI pricing docs) | — | Separate API key; category flags + scores; text (+ images if needed later); rate limits by account tier |
| **Google Perspective API** | **Free** today (~1 QPS default) | — | **Sunsetting Dec 31, 2026** — do **not** build new long-term dependency |
| **Azure AI Content Safety** (F0) | **5,000 text records / month** | ~$0.38 / 1k text records (S0) | Extra cloud account; strong categories; good if already on Azure |
| **AWS Comprehend DetectToxicContent** | **Not** in standard 12‑mo NLP free-tier list | ~$0.0005 / 100 chars (min 3 units/request) | Fine at MVP volume; adds AWS surface if stack stays GCP-only |
| **Anthropic** (summaries) | N/A for moderation | Usage-based | **No dedicated moderation endpoint** — keep for digests, not UGC classification |
| **bad-words** / profanity npm lists | Free | — | Slightly better than raw keywords; still high false-positive rate |
| **Hive, Sightengine, Checkstep, etc.** | Trials / sales-led | Often **$100–500+/mo** and up | Full UGC platforms — overkill for short condition notes until volume, images, or legal exposure justify |

**Volume context:** Short text reports at regional MVP scale are usually **well inside** free tiers (OpenAI moderation, Azure F0) if each submit is one API call.

#### Recommended path for this app (tradeoffs)

| Phase | Approach | Why |
|-------|----------|-----|
| **D0 (now)** | Shipped queue + keywords + human review | Infrastructure correct; policy TBD |
| **D1 (first automation)** | **OpenAI Moderation API** in `submitConditionReport` → **hold** (not auto-reject) when `flagged` or score above threshold; store `moderationReason` + category scores on doc | **$0 at MVP volume**; one HTTP call; fits existing Cloud Functions; no dashboard lock-in |
| **D1b (same release)** | **Rate limit** per UID + max length (extend zod); optional **hold-all** for first N reports from new accounts | Stops spam without ML; requires **(Phase C) Auth** for durable identity |
| **D1c (same release)** | **Paddling allowlist** in repo — terms that must never single-handedly trigger hold | Reduces false positives from generic toxicity models |
| **D2 (if OpenAI undesirable)** | **Azure Content Safety F0** as alternate provider behind a small `ModerationClassifier` interface | 5k/month free; more setup if GCP-only today |
| **D3 (scale / images / legal)** | Evaluate **Hive**-class platforms or dedicated human ops | When report volume, photo UGC, or compliance needs exceed function + queue |

**Do not:** Auto-**reject** on ML alone for safety-adjacent paddling notes (false negatives/positives); prefer **hold → human** or **hold → approve with audit**. **Do not** adopt Perspective for new work (sunset 2026).

**Integration sketch (D1):** `evaluateKeywordHold` → `classifyReportText` (provider) → `moderationStatus` + `moderationReason` + optional `moderationScores` map → existing queue + approved-only list/digest unchanged.

#### Checklist (Phase D / moderation — after policy doc)

- [ ] **(Phase D / mod)** **Moderation policy** — allowed content, prohibited content, hold vs reject rules, appeals, response SLA, liability copy (pairs with launch-detail disclaimers)
- [ ] **(Phase D / mod)** **Provider abstraction** — `ModerationClassifier` in functions (mock in unit tests); config in `config/moderation` (thresholds, provider id, enabled flags)
- [ ] **(Phase D / mod)** **OpenAI Moderation** (recommended v1) — secret `OPENAI_API_KEY`; hold above threshold; persist scores; fail-open vs fail-closed decision documented
- [ ] **(Phase D / mod)** **Paddling allowlist** — repo list + tests for false-positive regressions (“deadhead”, “dam release”, “strainer”, etc.)
- [ ] **(Phase D / mod)** **Rate limits** — per-UID submit caps (Firestore counter or sliding window); optional cooldown after reject
- [ ] **(Phase D / mod)** **Posture toggle** — `config/moderation.defaultStatus`: `approved` vs `held` for all new reports (product switch)
- [ ] **(Phase D / mod)** **Metrics** — log holds by reason (`keyword_hold`, `openai_flag`, `rate_limit`); moderator time-to-review (manual or later dashboard)
- [ ] **(Phase D / mod)** **In-app report abuse** — “Report this note” → second queue or auto-hold (optional)
- [ ] **(Phase D / mod)** **Alt provider spike** — Azure Content Safety F0 only if rejecting OpenAI second vendor
- [ ] **(Phase D / mod)** Revisit **Hive-class** vendors when photo reports or social feed (Phase D) ships

Relates to **(Phase D) Reputation / trust**, **(Phase C) Auth**, and **(Phase E) Ops** (quotas, cost dashboards).

---

## Platform architecture (complete)

Target repo/platform architecture is **done** for the current design. Shipped highlights (do not re-open as platform waves):

| Area | Notes |
|------|-------|
| Monorepo / melos / preflight / husky | Fast pre-commit; full gate on pre-push + CI (#24) |
| Coverage gates | 85% thresholds in `tooling/coverage.yaml`; CI enforces |
| Design system goldens + CI | Goldens on `macos-latest`; Ubuntu excludes `golden` tag |
| `@riverpod` codegen | Conditions, map, hydro, app shell, `packages/routing/` (#20–#23, #30) |
| Router package | `goRouterProvider`, redirects, gate screens in `packages/routing/` (#26, closeout) |
| `Result<T, AppFailure>` | Conditions, hydro, map boundaries (#28, #32, #33) |
| Feature layering | Conditions + map `presentation/`; token/web gates in routing (#35, #36, closeout) |
| Client telemetry v1 | Router screen tracking via `AnalyticsNavigatorObserver`; debug/no-op client; `report_submit_success` event |
| Integration tests (E2E) | Token gate + map → launch detail; CI Linux deps (#22, #25, #27) |

**Canonical design reference:** `docs/ARCHITECTURE.md` (package graph, layering, current implementation status).

### Platform follow-ups (deferred / partial)

Revisit when a product slice needs them — not blocking Phase C:

| Item | Status | Notes |
|------|--------|-------|
| **Mapbox mixin device coverage** | Partial | `lib/src/presentation/mapbox/` excluded from unit-coverage gate; add integration/device tests for camera, markers, style, route mixins |
| **`custom_lint` wiring** | Deferred | Analyzer version conflict with `riverpod_generator`; using `riverpod_lint` via `analysis_server_plugin` until deps align |
| **Riverpod-in-domain migration** | Partial | Repository DI tokens in domain; presentation providers still in feature packages |
| **`CancelToken` in domain HTTP contract** | Partial | Done in conditions; extend when adding HTTP in other features |
| **`INTEGRATION_MAP_STUB` branch** | Partial | Compile-time flag on `MapRoute`; covered by integration tests, not default unit tests |
| **Firebase bootstrap failure path** | Partial | `app_bootstrap.dart` Firebase init only exercised when `USE_FIREBASE=true` on device |
| **`eddyscout_map` core type re-exports** | Deferred | Barrel still re-exports `LaunchPoint` from core for ergonomics |
| **Hydro geodesy export coupling** | Deferred | `hydro_routing` data layer used directly by map presentation |

---

## Engineering standards (when building)

Apply these **with** the product slice that needs them — not as standalone platform waves:

| When you add… | Also do… |
|---------------|----------|
| **New Riverpod provider** | Use `@riverpod` codegen (`docs/CODEGEN.md`, `docs/STATE_MANAGEMENT.md`) |
| **New package I/O** (HTTP, callables, file load) | Return `Result<T, AppFailure>` or surface typed `AppFailure` via `AsyncError`; wire `CancelToken` per `docs/NETWORKING.md` (conditions is the reference) |
| **New user-facing screen** | Build in `packages/features/<name>/presentation/`; bind routes from `apps/eddyscout/lib/routing/app_routes.dart`; add path to `AnalyticsScreenNames` (screen views are automatic via router observer) |
| **New design-system widget** | Add golden test (`docs/TESTING.md`; `packages/design_system/test/goldens/`) |
| **New critical user journey** | Add or extend `apps/eddyscout/integration_test/` per `docs/TESTING.md` integration criteria |
| **New conversion / goal flow** | Add `AnalyticsEvent` per `docs/ANALYTICS.md` taxonomy (no PII in parameters) |
| **Edit launch detail UI** | Extract new sections into separate part files/widgets; avoid growing `widgets_conditions.dart` / `widgets_reports.dart` in place |
| **Authentication / saved identity** | Add `flutter_secure_storage` for tokens/credentials; add session auth router guards beyond Mapbox token/web redirects (`docs/NAVIGATION.md`, `docs/SECURITY.md`) — see **(Phase C) Auth** below |
| **Multi-tab navigation** | Use `StatefulShellRoute` (`docs/NAVIGATION.md`) |
| **Remote image UI** | Use `CachedNetworkImage` sized to display dimensions (`docs/PERFORMANCE.md`) |

### Infra bundled with product features

| Product trigger | Engineering work |
|-----------------|------------------|
| **(Phase C) Auth** / saved routes needing identity | `flutter_secure_storage`, session router guards, auth feature package |
| **Firebase-backed features** (reports, moderation, LLM Callables) | **Dev / prod aliases configured** (§ Firebase environments); finish deploy runbook + default-to-dev client selection |
| **Tab shell** (e.g. map + trips + profile) | `StatefulShellRoute`, shell routes in `packages/routing/` |
| **(Phase D) Media** / trip cards with photos | `CachedNetworkImage`, image sizing, optional upload pipeline |
| **New HTTP-heavy feature** | Extend `CancelToken` + `Result` pattern from conditions to that feature's repos |

### Integration test backlog

Add E2E coverage when the corresponding product slice ships (not before):

- **Report submit journey** — when moderation or report UX changes materially
- **Degraded / offline conditions** — when offline or cached conditions ship
- **Auth session flow** — with **(Phase C) Auth**

Budget: at most **one new** `integration_test/` file per product epic unless justified in the PR.

---

## Phasing

### Recommended next implementation

**Now (infra — Phase C):** **Firebase environment wiring** (§ Firebase environments) — projects and CLI aliases exist; finish mirroring both Console projects, default local builds to **dev**, and document deploy order. Reduces risk of test data and config changes on the MVP project.

**Next (product — Phase C):** **Moderation manual QA** (prefer **dev** once mirrored; prod acceptable interim); then **launch coordinate quality** — **two-pin model** (access vs water entry), catalog pin realignment, water-only polylines / mainstem geometry hygiene. Portland metro Overpass geometry, A\*, cross-system routing, reachability / suggested trips indexes, and **Trips from here** UI are shipped; moderation **code** is shipped — env + QA remain.

**Done (platform):** Waves 1–3 — monorepo, `@riverpod`, Result boundaries, router package, feature presentation layering, app-shell closeout (#19–#36).

**Already shipped (context):** Route preview (v1) — planning mode on the map, put-in / take-out from launches, polyline along bundled hydro GeoJSON (`assets/hydro/`; Willamette Portland reach first). Multi-stop routing, GPX export/import, saved routes with local persistence, map-first UX with bottom sheets and 4-tab shell.

---

## Master implementation checklist (living)

Single list of **everything** tracked for build progress. Tags show the original phase/pillar. Update `- [ ]` → `- [x]` here only (no duplicate subsection checklists).

### Shipped

- [x] **(Phase A)** Map + Mapbox + expanded regional launch pins
- [x] **(Phase A)** Tap launch → detail with **NWS** weather (Open-Meteo fallback), **USGS** flow where linked, **NOAA** tides, exposure/tide tags
- [x] **(Phase A)** **NWS marine** on launch detail (Coastal Waters Forecast / zone extract; not `/zones/marine/{id}/forecast`)
- [x] **(Phase A)** Local Mapbox token via `.local.env` + script
- [x] **(Phase A)** In-app **safety / disclaimer** on launch detail (extend globally as needed)
- [x] **(Phase A)** **Stub Go/No-Go** rules engine (wind, marine keywords, coarse cfs by river class; marginal / no-go / insufficient data)
- [x] **(Phase B)** Per-launch **cfs bands** (`LaunchFlowBands`; evaluator prefers bands, else river-class fallback)
- [x] **(Phase B)** **Skill profile** (beginner / intermediate / advanced) → wind thresholds + `SharedPreferences` + UI on launch detail
- [x] **(Phase B)** **Forecast time hint** (`periodStart` low-light hours → info only)
- [x] **(Phase B)** Gust-aware wind + marine text + flow rules in evaluator
- [x] **(Firebase)** Repo `firebase/` Functions (`us-west2`): `submitConditionReport`, `listConditionReports`, `summarizeLaunchReports`, `summarizeConditions` (Anthropic; deploy + secrets)
- [x] **(Firebase)** Firestore `conditionReports` writes **only** from Admin SDK; Callables from client; rules deny broad client access
- [x] **(Firebase)** Flutter: `firebase_core`, `cloud_functions`, `firebase_auth` (anonymous), `USE_FIREBASE`, JSON payload for summaries
- [x] **(Firebase)** **Report conditions** sheet + **AI summary** card when Firebase init succeeds
- [x] **(Firebase)** Cloud Run **invoker** + Android callable auth path (see `firebase/DEPLOY.md`)
- [x] **(Reports)** List recent reports per launch — `listConditionReports`; time-ordered list; light attribution
- [x] **(Reports)** AI digest of recent reports — `summarizeLaunchReports`; cache (`launchReportDigests`) + rate limits (`reportDigestRate`)
- [x] **(Reports)** Trust copy on digest; raw report list below digest on launch detail
- [x] **(Phase D)** In-app condition reports **reader + digest** (same as **Reports** rows above)
- [x] **(Phase E)** **Default model** path — Haiku via Cloud Function for summaries
- [x] **(Phase E)** **Snapshot summary (v1)** — `summarizeConditions` + “Summarize with AI” on launch detail
- [x] **(Phase E)** **Reports digest** (community notes paraphrase; see **Reports** rows above)
- [x] **(Infra)** Result-based providers + cancellation (CancelToken / callable cancel guards) for conditions, reports, and AI summary
- [x] **(Infra)** Client telemetry v1 — router screen tracking, debug/no-op `AnalyticsClient`, `report_submit_success` event

### Not yet

> **Gate:** Phase C items below are ready to implement — platform architecture is complete (§ Platform architecture). Firebase-backed manual QA: use **`eddyscout-dev`** when mirrored; until then prod (`eddyscout-c29b9`) is the practical fallback.

- [ ] **(Infra / Firebase)** Environment wiring — see § Firebase environments checklist (aliases **configured**; default-to-dev + dual deploy **remaining**)
- [x] **(Reports / mod)** Moderation — admin queue, TTL, keyword hold (optional report-abuse UX)
- [x] **(Phase C)** Route preview on map — planning mode, put-in / take-out from existing launches, path along bundled open hydro LineStrings (`assets/hydro/`; Willamette Portland reach first); not navigation-grade
- [x] **(Phase C)** Route planner follow-ups — more rivers / segment snap (`feat/route-planner-hydro-expansion`; Willamette + Columbia gorge hydro, edge snap, `PlannedRoute` domain model)
- [x] **(Phase C / R1a)** Route planner: Columbia OSM import — repeatable Overpass merge, Willamette mouth tied to real OSM vertices, geometry gate in CI (scoped PR before full R1)
- [x] **(Phase C / R1)** Route planner: reachability / suggested-trips gaps for pre-existing catalog launches — `port_of_camas`, `washougal_waterfront`, and `scappoose_bay_marina` on bundled geometry
- [x] **(Phase C / R1)** Route planner: Camas Slough / marina spur geometry — bundle OSM way `130204446` so Port of Camas marina routes to Columbia mainstem
- [x] **(Phase C / R1)** Route planner: import Columbia, Clackamas, slough, Tualatin, Sandy waterway geometry from OSM Overpass; validate connectivity; bundle as `assets/hydro/` (`feat/overpass-waterway-import`; seven bundled assets + `make hydro-check`)
- [x] **(Phase C / R1)** Route planner: NHD download + conversion script (`scripts/nhd/`; dev-time only — see `make hydro-nhd-run`)
- [x] **(Phase C / R2)** Route planner: upgrade Dijkstra to A* with priority queue and haversine heuristic
- [x] **(Phase C / R2)** Route planner: unified multi-system graph with cross-system routing (Willamette → Columbia confluence)
- [x] **(Phase C / R2)** Route planner: pre-computed binary graph serialization for faster cold start
- [x] **(Phase C / R2)** Route planner: retire unused `RouteFailureCode.noBundledLine` — unified graph uses `noRiverGeometryLoaded`
- [ ] **(Phase C / R3)** Route planner: **two-coordinate launch model** — separate **access** pin (map marker, parking / park entrance) from **water entry** pin (graph snap for routing); route polylines and distance use water entry only; access pin stays for discoverability (**build this before bulk pin migration**)
- [ ] **(Phase C / R3)** Route planner: **manual catalog pin realignment** — move launches with snap distance > 200 m to the water edge (satellite + water-trail cross-check); validate with `packages/features/hydro_routing/tool/launch_snap_report.dart` (**after two-pin lands, migrate both coordinates**)
- [ ] **(Phase C / R3)** Route planner: **water-only route polylines** — map LineLayer follows graph geometry only; no shore-to-river chords from inland access pins (interim UX fix; superseded per-launch once water entry is authoritative)
- [ ] **(Phase C / R3)** Route planner: **mainstem geometry hygiene** — launch connectors as side spurs only (never inlined into through-channel); prune OSM backtrack loops (e.g. Hayden Island); extract marina anchors (Port of Camas) from gorge mainstem *(Columbia lower spurs done; gorge through-channel hygiene ongoing)*
- [ ] **(Phase C / R3)** Route planner: pre-snap water-entry coordinates to graph vertices at build time; snap quality validation (partial: `make gen-launch-snap-check` enforces 200 m for launches with explicit water-entry coords)
- [ ] **(Phase C / R3)** Route planner: **snap quality CI gate** — warn/fail when catalog water-entry snap > 200 m (`bundled_launch_snap_test.dart` threshold today is 900 m reachability only)
- [x] **(Phase C / R3)** Route planner: reachability index per launch (nearby launches within 5/10/20 mi graph distance)
- [x] **(Phase C / R3)** Route planner: suggested trips from each launch (distance, time, waypoints)
- [x] **(Phase C / R3)** Route planner: regenerate reachability + suggested trips indexes with unified cross-system graph (`crossSystemReachability: true`)
- [x] **(Phase C / R3)** Route planner: "Trips from here" UI on place peek and launch detail (`feat/trips-from-here-ui`, PR #66)
- [x] **(Phase C)** Route planner: **personalized paddling speed** at sign-up / profile for trip-time estimates (default 4 km/h until set; optional learning from trip log)
- [ ] **(Phase C)** **Metric / imperial units** — user preference for distance (km/mi) and speed (km/h/mph) across settings, route planner, and saved routes
- [ ] **(Phase C / R4)** Route editing: arbitrary waypoints (drop pin on waterway, snap to graph)
- [ ] **(Phase C / R4)** Route editing: drag-to-edit polyline mid-points to reroute through alternate channels
- [ ] **(Phase C / R4)** Route editing: loop routes, island hopping, multi-day expedition waypoints
- [ ] **(Phase C / R4)** Route editing: route alternatives (shortest, most sheltered, scenic)
- [ ] **(Phase C)** GPX export / import
- [ ] **(Phase C)** Trip log
- [ ] **(Phase C)** Saved routes (v1) — name/description, categories, favorites, notes, private by default
- [ ] **(Phase C)** Saved routes metadata (v1) — difficulty, distance, time estimate, exposure, tide dependency, skill level
- [ ] **(Phase C)** **Auth** when identity is required for saves — accounts, `flutter_secure_storage` for credentials, session router guards (see § Engineering standards)
- [ ] **(Phase D)** **Multi-day trip planning (exploration)** — user research + product spec for **river multi-day** (daily legs, flow/camp constraints) vs **sea-kayak archipelago** (island hops, tide/current day windows, portage); define overnight-stop / campsite waypoint model; daily distance-time budgets; how per-day **route Go/No-Go** and float plans attach to each leg
- [ ] **(Phase D / R4)** **Multi-day trips (v1)** — plan a trip as ordered **days**, each with its own waypoints and overnight stop; per-day route preview + distance/time estimate; disconnected segments (archipelago/portage) with explicit gaps; save as multi-day saved route; GPX export per day or whole trip
- [ ] **(Phase D)** Planned trips / trip intent
- [ ] **(Phase D)** Moderation posture (policy + product, beyond technical queue above) — see § Content moderation automation
- [ ] **(Phase D)** **Live pins** only with explicit privacy/product decision
- [ ] **(Phase D)** User profile (v1) — basic stats, achievements placeholder, activity history
- [ ] **(Phase D)** Social feed (v1) — follow, likes/comments, basic posting
- [ ] **(Phase D)** Trip sharing (v1) — share cards + route screenshots + privacy controls
- [ ] **(Phase D)** Privacy controls (v1) — public/private trips, blur start/end, hide home launch
- [ ] **(Phase D)** Community reports expansion — hazards, debris, closures, boat traffic, algae blooms, wildlife
- [ ] **(Phase D)** Launch contributions (v1) — add/edit launches, photos, description edits, report inaccuracies *(merge via § Catalog distribution pipeline; not direct client writes to production catalog)*
- [ ] **(Phase D)** Reputation / trust (v1) — badges, verified reports, moderation hooks
- [ ] **(Phase E)** **Model-agnostic client** (`LlmClient`-style abstraction)
- [ ] **(Phase E)** **Chat + tools** (refresh conditions, list launches, etc.)
- [ ] **(Phase E)** **Route validation** (LLM + structured gaps, no invented hazards)
- [ ] **(Phase E)** **Safety intelligence** (canonical facts + optional LLM phrasing)
- [ ] **(Phase E)** **Ops** — quotas, logging, cost dashboards
- [x] **(Phase E)** Go / No-go typed reasons → localized labels (enum/codes + ARB; no raw reason strings in UI)
- [ ] **(Phase E)** **Route Go / No-Go (v1, hybrid)** — rules-first rollup across planned-route waypoints; polyline segment exposure sampling remains a later item
  - **Layer 1 (v1 core — ship gate):** Run existing `GoNoGoEvaluator` at each catalog waypoint (put-in / stops / take-out); roll up **worst** verdict (`noGo` > `marginal` > `insufficientData` > `go`); show rolled badge, **triggering stop name**, and localized reason chips on **map route preview** and **saved route detail**; reuse skill profile + launch-detail-style informational disclaimers (not a safety guarantee).
  - **Layer 2 (v1 optional stretch / default v1.1):** User-initiated **“Summarize route conditions”** button; LLM narrative card **grounded in Layer 1 JSON** + per-stop structured snapshots (same grounding rules as launch-detail `summarizeConditions`); narrative is **not** the verdict source—the Layer 1 badge always remains visible.
  - **Boundary:** **Route validation (LLM)** stays a separate Phase E item—plausibility coaching (leg length, segment fit), **not** cfs/wind verdict rollup.
  - **Later:** Sample exposure along polyline segments (roadmap “later”; out of v1 scope).
- [ ] **(Phase E)** Conditions intelligence (v2) — user thresholds (wind/current/temp), alerts, time windows
- [ ] **(Phase E)** Dynamic risk scoring (v1) — beginner safe / caution / expert only (wind/gust/current/tide/darkness/temp/exposure)
- [ ] **(Phase E)** Float plans (v1) — route + emergency contacts + return time + overdue reminder flow
- [ ] **(Phase E)** Safety alerts (v1) — “storm approaching”, “exceeds your threshold”, “current increasing”
- [ ] **(Phase F)** **Embedding model** (pluggable API / local)
- [ ] **(Phase F)** **Launch similarity (v1)** — profiles + nearest neighbors (“Similar ramps”)
- [ ] **(Phase F)** **Query paths** — from launch + optional NL
- [ ] **(Phase F)** **Route similarity** (after routes exist)
- [ ] **(Phase F)** **Hybrid search** (geo / river / skill filters)
- [ ] **(Phase F)** **Ops** — index versioning, backfill, no live cfs in embeddings
- [ ] **(Phase F)** AI route recommendations (v1) — “protected for wind”, “good on outgoing tide”, “beginner-friendly nearby”
- [ ] **(Phase F)** Route discovery surfaces (v1) — nearby, trending, beginner, scenic, weather-appropriate
- [ ] **(Phase R5)** Server-side routing: PostGIS + pgRouting for dynamic-weight routes and graph > 100k nodes
- [ ] **(Phase R5)** Route API: serverless endpoint; request waypoints + options → GeoJSON polyline response
- [ ] **(Phase R5)** Hybrid model: client-side for cached local; server for cross-region or closure-aware routing
- [ ] **(Phase R6)** Continental routing: regional geometry tiles + graph stitching + hierarchical routing
- [ ] **(Phase R6)** Incremental NHD import: HUC-region shapefiles → PostGIS → pgRouting network

### Remaining major features (from the feature table, not all on the build checklist)

These themes in **Feature list (your themes + gaps)** are still largely **future** relative to what the checklist tracks explicitly:

- **Map / discover:** skill & access **filters** on the map; **alerts** (flow/wind thresholds); **tab shell** (`StatefulShellRoute`) when adding secondary top-level destinations
- **Decide:** **route Go / No-Go** (aggregate verdict across planned waypoints/segments); richer **time windows**; **cold water / safety UX** beyond the launch disclaimer
- **On-water:** **User location + bearing** to waypoint; **offline** maps / cached conditions
- **Data / trust:** **Access / permits / tribal** metadata + UI tags
- **Plan:** **multi-day trip planning** (river descents + archipelago hops; daily legs, overnight stops, per-day conditions); saved routes metadata expansion
- **Social (beyond reports):** **Trip log** as history; fuller **social** (find paddlers, etc.) with the MVP non-goals still in mind

Additional feature themes explicitly on the product roadmap but not fully itemized above yet:

- **Trip recording (GPS)** — record/pause/resume/background + distance/duration/speed; later wind/current/tide-adjusted metrics
- **Live navigation** — on-route guidance, off-route detection, audible/vibration alerts, offline nav
- **Offline support** — offline maps, offline routes, offline navigation, offline recording, background sync on reconnect
- **Media** — photos/videos, trip cards, auto-generated summaries (`CachedNetworkImage` when showing remote images; see § Engineering standards)
- **Search & filtering** — route + launch search with facets (distance/difficulty/water type/wind protection/tide suitability/scenic)
- **Gamification** — achievements, challenges, streaks

---

## Multi-day trip planning (exploration)

Many paddlers plan **multi-day** trips—not single put-in/take-out day paddles. EddyScout should eventually support both dominant patterns:

| Pattern | Examples (PNW) | Planning needs |
|---------|------------------|----------------|
| **River multi-day** | Willamette/Columbia multi-day descents; multi-day on Class I–II stretches | Daily **distance/time budgets**; flow trend over days; camp/overnight stop waypoints; strainer/hazard notes by river mile |
| **Sea kayak / archipelago** | San Juan Islands, Puget Sound hops, coastal camp-to-camp | **Tide/current windows per day**; marine forecast day blocks; island-hopping segments; **portage** or launch gaps between water bodies; exposure along open crossings |

### Product questions (exploration)

- **Day as first-class object** — Is a multi-day trip an ordered list of **days**, each with waypoints + route polyline, rather than one monolithic route?
- **Overnight stops** — Catalog launches vs user-placed camp pins vs editorial campsite POIs?
- **Disconnected geometry** — How to represent archipelago legs (segment A → portage → segment B) without implying continuous water?
- **Conditions over time** — Per-day go/no-go rollup vs “best departure window” within a trip date range (ties to **time windows**, **route Go/No-Go**, **float plans**).
- **Offline** — Multi-day trips amplify need for offline maps, saved routes, and last-known conditions on route.

### Suggested v1 slice (after R4 routing basics)

1. **Trip = N days**, each day has waypoints + optional overnight stop label.
2. **Per-day** route preview (reuse planner graph per leg).
3. **Per-day** distance, time estimate (paddling speed), and conditions summary when data exists.
4. **Save / GPX** — export whole trip or single day.

Deeper v2: tide-optimized day start times, resupply points, group trip sharing, LLM “sanity check” per day (Assist pillar).

---

## LLM / API strategy

- **Provider-agnostic:** One interface (e.g. `LlmClient`) with per-provider adapters (Anthropic, OpenAI, others). Model id + max tokens + tool schema passed per call.
- **Cost:** Prefer **Haiku-class** models for v1 chat and summaries; reserve larger models for optional “deep dive” if product demands it.
- **Grounding:** System prompts require the model to **only** cite numbers that appear in tool results or provided JSON; if unknown, say so.
- **Non-goal:** The LLM is not the legal “decision”—copy stays informational; Go/No-Go remains rules + human judgment.

---

## Embeddings / vector search (summary)

- **Possible:** Yes. Similarity search is **standard**: embed fixed text profiles for launches (and later routes), store vectors, retrieve **k nearest neighbors**; optionally merge scores with metadata filters.
- **Not magic:** Quality depends on **what you embed** (rich, consistent descriptions + tags) and **hybrid filters** (region, river, skill). Otherwise “similar” can mean linguistically close but geographically silly.
- **Conditions:** Do **not** rely on embeddings for “similar **current** weather”—that’s real-time data. Use embeddings for **place and route character**; keep conditions as separate queries.

---

## Data sources (target)

| Source | Use |
|--------|-----|
| **Mapbox** | Basemap, style, later offline |
| **OpenStreetMap / Overpass** | Waterway geometry (`waterway=river`, `waterway=canal`, `natural=water`, `water=lake`); basis for routable graph |
| **US NHD (National Hydrography Dataset)** | Higher-quality centerlines for US rivers/streams; alternative or supplement to OSM for accuracy |
| **USGS** | River discharge / gauge height |
| **NOAA** | Weather, marine text; tides/currents where applicable |
| **Crowd / editorial** | Hazards, wood, subjective stretch quality |
| **LLM provider (optional)** | e.g. Anthropic / OpenAI for summaries & chat—**keys** via env / backend; not required for core map + conditions |
| **Embedding provider (optional)** | API or local model for **launch/route vectors**; often separate from chat LLM; **model-agnostic** storage (dimension + provider id per index) |

Attribute and comply with each provider’s terms in the app.

---

## Waterway routing strategy

The routing engine is the foundation for trip planning, discovery, and on-water features. The strategy below describes how the system should evolve from the current single-river bundled GeoJSON to a scalable graph-routed architecture.

### Core principle

**Do not connect launches directly.** Route along actual waterway geometry. Direct launch-to-launch edges lose:

- Actual river/channel shape (bends, islands, channels)
- Accurate distance
- Alternate routes (side channels, portage options)
- Scalability (adding a launch means re-wiring all connections)

Instead: **waterway geometry → graph → snap launches at water entry → route through graph**.

Catalog launches should expose **two coordinates** when they differ: **access** (map marker) and **water entry** (routing snap). A single inland pin forces shore-to-river chords in the polyline.

### Architecture layers

```
Waterway GeoJSON (OSM / NHD / curated)
  → Graph builder (nodes + undirected weighted edges)
    → Launch snapper (nearest graph vertex per launch)
      → Pathfinder (A* / Dijkstra)
        → GeoJSON polyline
          → Mapbox LineLayer display
```

### Phase R1: Full waterway geometry (current gap)

**Goal:** Import all routable waterways for Portland metro and greater PNW.

**Data sources (priority order):**

1. **OpenStreetMap via Overpass API** — query `waterway=river`, `waterway=stream`, `waterway=canal`, `natural=water`, `water=lake`, and `natural=coastline` for the target bounding box.
2. **US NHD (National Hydrography Dataset)** — higher resolution centerlines; supplement OSM where it lacks detail (smaller tributaries, accurate river mile alignment).
3. **OpenMapTiles** — pre-processed vector tiles if batch geometry extraction is easier than raw Overpass.

**Target river systems (Portland area):**

| System | Status |
|--------|--------|
| Willamette (main stem Portland reach) | Done (bundled GeoJSON) |
| Columbia (Portland–Sauvie–St. Helens) | **R1a + R1 done** — OSM Overpass import; Camas Slough + Washougal side spurs; Multnomah/Scappoose marina extension; mainstem loop pruning |
| Clackamas | **Done** — `clackamas_waterway.geojson` |
| Multnomah Channel / slough | **Done** — `slough_waterway.geojson`; **Camas Slough** spur for Port of Camas marina still open (~2.2 km to Columbia mainstem today) |
| Tualatin | **Done** — `tualatin_waterway.geojson` (no catalog launches yet) |
| Sandy | **Done** — `sandy_waterway.geojson` (`reach_id`: `sandy_main`) |

**Output:** One GeoJSON `FeatureCollection` per river system with `river_system` property; each feature is a `LineString` of centerline coordinates.

**Tasks:**

- [x] Write Overpass import script for Columbia lower + gorge (`scripts/overpass/fetch_columbia_waterway.py`)
- [x] Write Overpass query scripts for remaining Portland metro systems (`scripts/overpass/fetch_{clackamas,slough,tualatin,sandy}_waterway.py`, `fetch_all_portland_hydro.sh`)
- [x] Connect Willamette mouth via shared OSM vertices (no hand-drawn mouth connector)
- [x] Add bundled geometry gate — fail CI when any edge > 2000 m or confluence gaps > 12 m (`scripts/check_hydro_geometry.sh`)
- [x] Bundle as `assets/hydro/<system>_waterway.geojson` (seven systems + `confluence_bridges.json` placeholder)
- [ ] Validate geometry connectivity end-to-end for all confluences (Clackamas / Sandy joins still informational only)
- [ ] Merge disconnected segments within snap threshold (automated beyond vertex merge)
- [x] Add NHD download + conversion script for higher-quality alternatives (`scripts/nhd/README.md`)
- [x] Document geometry provenance per file in `scripts/README-hydro.md`

### Phase R1a: Columbia OSM import (scoped — ship before full R1)

**Goal:** Replace hand-curated Columbia mouth connector and land chords with repeatable OSM import; gate bundled geometry in CI.

**Scope (one PR, not all of R1):**

- [x] Import + merge real Columbia centerlines — Overpass merge of connected `waterway=river|canal|fairway` ways (`scripts/overpass/fetch_columbia_waterway.py`)
- [x] Connect at Willamette mouth using shared OSM vertices — read mouth from `willamette_waterway.geojson`; no hand-drawn mouth connector
- [x] Geometry gate — `scripts/check_hydro_geometry.sh` fails preflight when any edge > 2000 m or confluence gaps > 12 m
- [x] Geometry gate — `scripts/check_hydro_geometry.sh` fails preflight when any edge > 2000 m or confluence gaps > 12 m
- [x] Manual route check — Cathedral Park → Glenn Otto follows channel without land vees (regression: no shore chords, no mainstem loops, no inlined launch anchors on through-route)
- [x] Unit tests for geometry gate (`scripts/hydro/test_check_geometry.py`)

**Known launch snap gaps (unified graph; run `dart run tool/launch_snap_report.dart`):**

| Launch | Snap to bundled geometry | Action |
|--------|--------------------------|--------|
| Washougal Waterfront Park | ~610 m | Realign access + water entry after two-pin model |
| Jefferson St (Milwaukie) | ~577 m | Realign pins to ramp |
| Portland Boathouse | ~564 m | Realign pin to dock |
| Glenn Otto Park | ~547 m | Realign pin to Sandy River beach |
| Sellwood Riverfront | ~435 m | Realign pin to beach |
| Cathedral Park | ~407 m | Realign pin to boat ramp |
| Tom McCall / River Place | ~355 m | Realign pins to permitted water access |
| George Rogers Park | ~325 m | Realign pin to beach |
| Swan Island Boat Ramp | ~242 m | Realign pin to ramp |
| Port of Camas marina | ~0 m* | *Geometry extended to pin; marina still ~2.2 km off mainstem channel — **R1** Camas Slough OSM spur (`130204446`) |
| Vancouver Wintler / Frenchman's Bar / Scappoose / St Helens | ~0 m* | *Launch spur geometry meets pin; access pin may still be inland — two-pin model clarifies |

**Out of scope for R1a (defer to full R1):** NHD pipeline as primary source.


### Phase R2: Graph construction improvements

**Current state:** `RiverLineGraph` builds undirected edges with haversine weights, 12 m vertex merge threshold.

**Improvements:**

- [x] **Priority queue Dijkstra or A\*** — `AStarMinHeap` replaces O(n²) linear scan
- [x] **A\* heuristic** — haversine straight-line distance to destination; admissible for undirected waterway graphs
- [x] **Vertex merge spatial index** — `VertexMergeIndex` in graph build (replaces O(n²) `findOrAdd` scan)
- [x] **Confluence bridge endpoint index** — `GraphSnapIndex.nearestVertexIndex` in `addConfluenceBridges`
- [ ] **Configurable vertex merge threshold** — 12 m is tight for NHD; test 20–30 m for denser datasets
- [ ] **Edge metadata** — store `river_system`, optional `one_way` flag (for future flow direction), optional hazard/closure flag
- [x] **Multi-system graph** — single unified graph with labeled edges; cross-system routing where waterways physically connect (e.g. Willamette → Columbia confluence)
- [ ] **Bidirectional edges with direction cost** — downstream cheaper than upstream (integrate average current speed when available)
- [x] **Graph serialization** — pre-compute graph offline; ship as binary adjacency list (`unified_hydro_graph.bin`; `make gen-hydro-graph-check` in CI)

**Performance targets:**

| Metric | Target |
|--------|--------|
| Portland metro graph size | 20k–50k nodes |
| Route computation (client-side) | < 200 ms for 50k nodes with A* |
| Cold start (graph load + parse) | < 500 ms from serialized binary |

### Phase R3: Launch snap and discovery

**Current state:** Dynamic snap at route time via `_nearestSnap`, which linearly scans all vertices and edges O(V+E) per endpoint (twice per route). Acceptable at ~1k unified vertices today. Reachability and suggested-trip indexes ship with `crossSystemReachability: true`. **Trips from here** UI ships on launch detail / place peek. Catalog launches use a **single** lat/lon for both map marker and routing — inland pins produce visible land chords and “vee” polylines.

**Two-coordinate launch model (next):**

| Field | Purpose | Shown on map | Used for routing |
|-------|---------|--------------|----------------|
| `accessLatitude` / `accessLongitude` | Parking, park entrance, ramp approach | Yes (primary marker) | No |
| `waterEntryLatitude` / `waterEntryLongitude` | Nearest shore / dock / beach put-in on water | Optional secondary or hidden | Yes (snap + polyline endpoints) |

Until both exist, default water entry to access for backward compatibility. Migration order: **schema + planner first**, then realign bad pins (table in R1a), then tighten CI gate to 200 m on water entry only.

**Improvements:**

- [ ] **Two-coordinate launch model** — `LaunchPoint` access vs water-entry fields; routing + polylines use water entry only (see master checklist)
- [ ] **Manual pin realignment** — satellite placement for launches > 200 m snap (see R1a table)
- [ ] **Water-only route polylines** — `_buildPolyline` omits inland access chords (interim until all launches have water entry)
- [ ] **Pre-snap at build time** — store `waterEntryGraphVertex` or snapped coords in catalog; validate during codegen / asset pipeline
- [ ] **Spatial index for route-time snap** — replace O(V+E) `_nearestSnap` with grid or R-tree lookup within `maxSnapMeters`; required before 20k+ node graphs and for R4 arbitrary waypoints / drop-pin routing
- [ ] **Snap quality gate** — fail CI when water-entry snap > 200 m; `launch_snap_report.dart` for local audit
- [x] **Reachability index** — BFS from each launch up to distance thresholds; bundled at `assets/data/launch_reachability_index.json`

```json
{
  "launchId": "stjohns",
  "nearbyLaunches": {
    "5mi": ["cathedralPark", "universityOfPortland"],
    "10mi": ["sellwoodRiverfront", "willamettePark"],
    "20mi": ["sauvieIsland", "milwaukieBay"]
  }
}
```

- [x] **Suggested trips** — pre-computed one-way and round-trip suggestions per launch; bundled at `assets/data/launch_suggested_trips_index.json`

```json
{
  "launchId": "cathedralPark",
  "suggestedTrips": [
    {
      "destination": "sellwoodRiverfront",
      "distanceKm": 8.2,
      "estimatedMinutes": 123,
      "waypoints": ["cathedralPark", "sellwoodRiverfront"]
    }
  ]
}
```

- [x] **UI: "Trips from here"** — nearby launches and suggested trips on place peek and launch detail (PR #66)
- [x] **UI: Trip length filters** — short (< 5 mi), medium (5–10 mi), long (> 10 mi) on suggested trips (PR #66)

### Phase R4: Multi-stop and advanced routing

**Current state:** Multi-stop works via chained segments on same river system.

**Improvements:**

- [x] **Cross-system routing** — route across Willamette → Columbia confluence; unified multi-system graph (R2)
- [ ] **Arbitrary waypoints** — allow user to drop a pin on any waterway (snap to nearest graph vertex); not just catalog launches
- [ ] **Loop routes** — detect same start/end; offer "out-and-back" or "loop via alternate channel"
- [ ] **Island hopping / archipelago routes** — multiple segments with portage indicators between disconnected water bodies
- [ ] **Multi-day expedition support** — save waypoints as overnight stops; segment time estimates per day
- [ ] **Drag-to-edit route** — user drags mid-point of polyline to reroute through a different channel; re-snap to graph and re-route affected segments
- [ ] **Route alternatives** — compute 2–3 route options (shortest, most sheltered, scenic) using edge attributes

### Phase R5: Server-side routing (scale)

**Current state:** 100% client-side. Acceptable for Portland (~20k–50k nodes).

**When to move server-side:**

- Graph exceeds ~100k nodes (multiple metro areas or regional coverage)
- Real-time hazard/closure data needs to modify graph weights dynamically
- Route sharing requires server-computed canonical polylines

**Architecture (when needed):**

```
Client → Route API (POST /routes/plan)
  → PostGIS graph stored in DB
  → pgRouting or custom A* on server
  → GeoJSON response
  → Mapbox display
```

- [ ] **PostGIS + pgRouting** — import graph edges as a routable network; use `pgr_astar` or `pgr_dijkstra`
- [ ] **Route API** — serverless function or lightweight service; request: `{waypoints: [{lat, lon}...], options: {avoidUpstream, preferSheltered}}`; response: GeoJSON polyline + metadata
- [ ] **Hybrid model** — client-side for cached local area; server for cross-region or dynamic-weight routes
- [ ] **Response time target** — < 500 ms for regional routes (Portland → Seattle waterway corridor)

### Phase R6: Continental routing

**Goal:** Portland → Seattle (or any coast-to-coast waterway route) is the same operation as Sellwood → St. Johns — the routing engine doesn't know or care about distance; it's just traversing a waterway graph.

**Requirements:**

- [ ] **Regional geometry tiles** — download/cache geometry per bounding box; don't ship entire US as bundled asset
- [ ] **Graph stitching** — merge regional graphs at boundary edges (river crosses tile boundary → shared vertices)
- [ ] **Hierarchical routing** — coarse graph (major rivers only) for long routes; fine graph for local segments; cascade for speed
- [ ] **Server-mandatory** — client can't hold 1M+ nodes in memory; all continental routes go through Route API
- [ ] **Incremental NHD import** — script to import NHD HUC-region shapefiles → PostGIS → pgRouting network

### Routing decision tree (implementation order)

```
1. Columbia OSM import + geometry gate (R1a)           ← DONE
2. Import remaining Portland-area waterway geometry (R1) ← DONE (Camas Slough spur still open)
3. Upgrade pathfinder to A* with priority queue        ← DONE
4. Cross-system routing (unified graph)                ← DONE (R2)
5. Reachability + suggested trips indexes              ← DONE (cross-system)
6. "Trips from here" UI                                ← DONE (PR #66)
7. Two-coordinate launch model (access + water entry)  ← NEXT
8. Manual pin realignment + water-only polylines
9. Mainstem geometry hygiene + snap quality CI gate
10. Pre-snap water entry at build time; spatial index for snap
11. Arbitrary waypoints + drag-to-edit
12. Server-side routing when graph > 100k nodes
13. Continental expansion
```

---

## MVP non-goals (until explicitly pulled in)

- Full social graph, DMs, or always-on live location
- National coverage before PNW is strong
- Scuba / dive-specific flows (unless scope is intentionally split)
- Guaranteed “safe” verdicts (copy must stay informational)
- LLM **inventing** hazards, closures, or flows not present in tool/API output
- LLM-only **Go/No-Go** without explicit rules + disclaimers

---

## Risks

| Risk | Mitigation |
|------|------------|
| **Liability** from automated Go/No-Go | Disclaimers; prefer “marginal”; no medical or rescue guarantees |
| **Wrong gauge for stretch** | Model gauge–segment links; show data source + timestamp |
| **Social abuse / harassment** | Reports, blocks, minimal PII; TTL on location-ish posts; § Content moderation automation (Phase D) |
| **Token / API costs** | Cache conditions; rate-limit; restrict geography early |
| **LLM hallucination next to safety** | Tool-grounding, strict system prompts, show sources; safety facts from canonical copy |
| **LLM spend / abuse** | Per-user or per-device quotas; Haiku by default; short context windows |
| **Bad similarity results** | Hybrid geo/skill filters; human-readable “why similar”; refresh embeddings when copy changes |
| **Catalog drift / stale pins** | Bundled catalog + CI snap gates today; § Catalog distribution pipeline when remote updates are needed |
| **Test data on production Firebase** | § Firebase environments — default dev project for local work; explicit prod deploy only |
| **Wrong Firebase project / UNAUTHENTICATED Callables** | Matching `google-services.json` to deploy target; SHA fingerprints per project (`firebase/DEPLOY.md`) |

---

## How to use this file

- **Platform vs product:** shipped platform architecture is summarized in § Platform architecture; ongoing engineering rules in § Engineering standards; product phases and checklist live in the sections below.
- Update the **Master implementation checklist** (`- [ ]` → `- [x]`) when you ship; keep **Recommended next implementation** and **Execution order** in sync when priorities change.
- Add **dates** or **PR links** inline next to items when helpful.
- Trim the feature table above if you descope; keep **pillars** stable for narrative.
