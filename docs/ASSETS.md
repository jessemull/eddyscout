# EddyScout — Asset Governance

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > this file.
>
> **AI agents:** Read and follow this file when adding, modifying, or organizing image, icon, font, animation, or data assets; when reviewing asset contributions to bundle size; or when naming asset files.

---

## Asset Directory Organization

```
assets/
├── images/          # Raster images (photos, backgrounds, illustrations)
├── icons/           # App icons and custom iconography
├── fonts/           # Bundled font files
├── data/            # Static data files (JSON, CSV)
├── hydro/           # Hydrological GeoJSON data (river geometries)
└── ...
```

- Keep assets organized by **type**, not by feature.
- Reference all asset directories in `pubspec.yaml` under the `assets:` key.
- Subdirectories within a category are allowed for further organization (e.g., `images/onboarding/`).

## Image Optimization Requirements

| Rule | Detail |
|------|--------|
| **Preferred format** | WebP for raster images (superior compression at equivalent quality) |
| **Fallback format** | PNG for images requiring transparency where WebP is not viable; JPEG for photos without transparency |
| **Max dimensions** | 2x the largest display size needed (e.g., 1024px wide for a 512dp-wide widget) |
| **Compression** | Lossless WebP for icons/UI elements; lossy WebP (quality 80–90) for photos |
| **Resolution variants** | Provide 1x, 2x, 3x variants for device-pixel-ratio scaling, or use SVG where appropriate |

- Run images through an optimizer (e.g., `cwebp`, `pngquant`) before committing.
- Do not commit unoptimized source images (PSD, TIFF, RAW) to the repository.

## SVG Rules

- Use **`flutter_svg`** for rendering SVG assets.
- Keep SVGs **simple**: flat shapes, no filters, no embedded raster images, no JavaScript.
- Remove unnecessary metadata, editor artifacts, and hidden layers before committing.
- Optimize with `svgo` or equivalent before adding to the repo.
- Prefer SVG over raster for icons and simple illustrations to avoid resolution variants.

## Animation Asset Rules

| Format | Package | Status |
|--------|---------|--------|
| **Lottie** | `lottie` | Allowed after evaluation per-use |
| **Rive** | `rive` | Allowed after evaluation per-use |
| **GIF** | (native) | Discouraged — prefer Lottie or Rive for smaller size and better performance |

- Each animation asset must be evaluated for file size, runtime performance, and licensing before inclusion.
- Animations should be optional enhancements, not load-bearing UI — the screen must be usable without them.
- Keep animation files under **500 KB** per asset.

## Bundle-Size Governance

- Monitor asset contribution to APK and IPA size using `flutter build --analyze-size`.
- Total asset contribution should not exceed **20%** of the release binary without justification.
- Review asset size impact in PRs that add or modify assets.
- Remove unused assets promptly — do not leave dead assets in the tree.
- For large data files (GeoJSON, JSON datasets), evaluate whether they should be fetched at runtime instead of bundled.

## Font Management

- Use **Google Fonts** via the `google_fonts` package for dynamic font loading (preferred for reducing bundle size).
- If bundling fonts, place `.ttf` or `.otf` files in `assets/fonts/` and declare in `pubspec.yaml`.
- Limit to **2 font families** maximum (one for headings, one for body) to keep bundle size reasonable.
- Declare font licenses in a `NOTICES` or `licenses` file.
- Use Material 3's type scale rather than custom font size definitions where possible.

## Localized Asset Rules

- If an asset contains text (e.g., an illustration with labels), provide locale-specific variants.
- Organize localized assets in subdirectories by locale: `assets/images/en/`, `assets/images/es/`.
- Use the localization system to select the appropriate asset path at runtime.
- Non-text assets (icons, abstract illustrations) should be locale-independent.

## Asset Naming Conventions

| Rule | Example |
|------|---------|
| **snake_case** | `launch_pin_icon.svg`, `onboarding_background.webp` |
| **Descriptive** | `river_flow_chart.png` not `img_01.png` |
| **No spaces or special characters** | Use underscores, not hyphens or spaces |
| **Include variant suffix** | `app_icon_foreground.png`, `launch_marker_selected.svg` |

- Names should convey the asset's purpose without needing to open the file.
- Group related assets with a common prefix: `map_pin_default.svg`, `map_pin_selected.svg`, `map_pin_disabled.svg`.
