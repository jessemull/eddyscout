# EddyScout — product roadmap

High-level feature map for a PNW-focused kayak companion: **decision-first**, **local nuance**, **conditions fusion**, **honest safety framing**, and **Flutter + Mapbox** on the client. This document is a living plan; tick or adjust as you ship.

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
| **Decide** | Fuse weather, wind, flow, tides where relevant; output Go / marginal / no-go + reasons. |
| **Assist (LLM)** | Summaries, Q&A, and coaching **grounded in fetched data + curated metadata**—not a replacement for judgment. |
| **Plan** | Routes, put-in / take-out, GPX. |
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
| 5 | **Go / no-go** | Clear call + reasons + **marginal**; legal/UX **disclaimer** | Include cold water and skill; avoid false confidence. |
| 6 | **Route planner** | Put-in / take-out, snap or align to water; later drift vs wind | Needs **river geometry** or curated segments. |
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

## Phasing

### Recommended next implementation

**Phase C — Route planner MVP:** put-in / take-out selection, water-aligned geometry TBD, and a thin path toward GPX later. Condition reports (list + AI digest on launch detail) are in place; the next large product slice is planning on the map rather than more report plumbing—unless you prefer **moderation / abuse** for reports first.

---

## Implementation checklist (living)

Use `- [x]` / `- [ ]` in source; render as checkboxes in most Markdown viewers.

### Phase A — Solo paddler loop (no auth)

- [x] Map + Mapbox + expanded regional launch pins
- [x] Tap launch → detail with **NWS** weather (Open-Meteo fallback), **USGS** flow where linked, **NOAA** tides, exposure/tide tags
- [x] **NWS marine** on launch detail: `api.weather.gov` does not implement `/zones/marine/{id}/forecast`; app uses **Coastal Waters Forecast (CWF)** product text + zone extract instead
- [x] Local Mapbox token via `.local.env` + script
- [x] In-app **safety / disclaimer** on launch detail (extend globally as needed)
- [x] **Stub Go/No-Go** rules engine (wind, marine keywords, coarse cfs by river class; marginal / no-go / insufficient data)

### Phase B — Decision engine v1

- [x] Per-launch **cfs bands** (`LaunchFlowBands`; evaluator prefers bands, else river-class fallback)
- [x] **Skill profile** (beginner / intermediate / advanced) → wind thresholds + `SharedPreferences` + UI on launch detail
- [x] **Forecast time hint** (`periodStart` low-light hours → info only)
- [x] Gust-aware wind + marine text + flow rules in evaluator

### Firebase backend (reports + AI summary)

- [x] Repo `firebase/` Functions (`us-west2`): `submitConditionReport`, `listConditionReports`, `summarizeLaunchReports`, `summarizeConditions` (Anthropic via `ANTHROPIC_API_KEY`; deploy + secrets)
- [x] Firestore `conditionReports` writes **only** from Admin SDK; Callables from client; rules deny broad client access
- [x] Flutter: `firebase_core`, `cloud_functions`, `firebase_auth` (anonymous), `USE_FIREBASE`, JSON payload for summaries
- [x] **Report conditions** sheet + **AI summary** card when Firebase init succeeds
- [x] Cloud Run **invoker** + Android callable auth path debugged (operational; see `firebase/DEPLOY.md`)

#### Condition reports — in-app reader + daily digest (follow-up)

Launch detail shows **Community digest (AI)** (recent reports paraphrased; Firestore-backed cache + per-user rate limits on fresh generations) and **raw recent reports** underneath.

- [x] **List recent reports per launch** — Callable `listConditionReports(launchId, limit)` (or scoped Firestore reads after security review); time-ordered list, light attribution (e.g. Anonymous)
- [x] **AI summary of recent reports** — Callable `summarizeLaunchReports` over the latest N submissions (not strict calendar-day); grounded digest; server cache (`launchReportDigests`) + rate limits (`reportDigestRate`)
- [x] **UX / trust** — subjective / not-official copy on digest; raw list below digest; optional report-abuse later
- [ ] **Moderation (later)** — admin queue, TTL, keyword hold

### Phase C — Plan + log

- [ ] Route planner MVP (put-in / take-out, water-aligned geometry TBD)
- [ ] GPX export / import
- [ ] Trip log
- [ ] **Auth** when identity is required for saves

### Phase D — Community

- [ ] Planned trips / trip intent
- [x] **In-app condition reports reader + digest** (ties to Firebase follow-up above)
- [ ] Moderation posture
- [ ] **Live pins** only with explicit privacy/product decision

### Phase E — Assistive intelligence (LLM)

- [ ] **Model-agnostic client** (`LlmClient`-style abstraction)
- [x] **Default model** path — Haiku via Cloud Function for summaries
- [x] **Snapshot summary (v1)** — `summarizeConditions` + “Summarize with AI” on launch detail
- [x] **Reports digest** — same epic as checklist under Firebase follow-up
- [ ] **Chat + tools** (refresh conditions, list launches, etc.)
- [ ] **Route validation** (LLM + structured gaps, no invented hazards)
- [ ] **Safety intelligence** (canonical facts + optional LLM phrasing)
- [ ] **Ops** — quotas, logging, cost dashboards

### Phase F — Semantic discovery (embeddings)

- [ ] **Embedding model** (pluggable API / local)
- [ ] **Launch similarity (v1)** — profiles + nearest neighbors (“Similar ramps”)
- [ ] **Query paths** — from launch + optional NL
- [ ] **Route similarity** (after routes exist)
- [ ] **Hybrid search** (geo / river / skill filters)
- [ ] **Ops** — index versioning, backfill, no live cfs in embeddings

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
| **USGS** | River discharge / gauge height |
| **NOAA** | Weather, marine text; tides/currents where applicable |
| **Crowd / editorial** | Hazards, wood, subjective stretch quality |
| **LLM provider (optional)** | e.g. Anthropic / OpenAI for summaries & chat—**keys** via env / backend; not required for core map + conditions |
| **Embedding provider (optional)** | API or local model for **launch/route vectors**; often separate from chat LLM; **model-agnostic** storage (dimension + provider id per index) |

Attribute and comply with each provider’s terms in the app.

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
| **Social abuse / harassment** | Reports, blocks, minimal PII; TTL on location-ish posts |
| **Token / API costs** | Cache conditions; rate-limit; restrict geography early |
| **LLM hallucination next to safety** | Tool-grounding, strict system prompts, show sources; safety facts from canonical copy |
| **LLM spend / abuse** | Per-user or per-device quotas; Haiku by default; short context windows |
| **Bad similarity results** | Hybrid geo/skill filters; human-readable “why similar”; refresh embeddings when copy changes |

---

## How to use this file

- Update the **Implementation checklist** (`- [ ]` → `- [x]`) when you ship; keep **Recommended next implementation** in sync when priorities change.
- Add **dates** or **issue links** inline next to items if you track work elsewhere.
- Trim the feature table above if you descope; keep **pillars** stable for narrative.
