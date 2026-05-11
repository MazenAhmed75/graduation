# Design System Document

## 1. Overview & Creative North Star: "The Mindful Curator"

This design system is built to transcend the "utility" of a tracking app and move into the realm of a sophisticated digital sanctuary. Our Creative North Star is **The Mindful Curator**.

In a world of cluttered dashboards and rigid grids, this system favors **Atmospheric Organization**. We break the "template" look by utilizing wide apertures (generous white space - `spacing: 3`), intentional asymmetry in data visualization, and a "layered paper" approach to depth. The goal is to make the user feel like they are interacting with a high-end editorial journal—organized and professional, yet soft, human, and deeply trustworthy.

---

## 2. Colors & Tonal Depth

The palette is rooted in organic, botanical tones—deep forest greens (`primary_color_hex: #3C6A35`) and muted slate blues (`secondary_color_hex: #4A6267`)—designed to lower the user's heart rate while maintaining a professional "ledger" feel. The neutral base color is `#F8FAF2`.

### The "No-Line" Rule
**Prohibit 1px solid borders for sectioning.** To achieve a premium feel, boundaries must be defined solely through background color shifts or tonal transitions. Use `surface-container-low` for large section backgrounds against a `surface` base.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers. Use the following logic for nesting to create natural depth without visual noise:
*   **Base Layer:** `surface` (`neutral_color_hex`) - The canvas.
*   **Primary Sectioning:** `surface-container-low` (#f1f5eb) - For grouping related tracking modules.
*   **Interactive Cards:** `surface-container-lowest` (#ffffff) - To create a "pop" of clarity and focus.
*   **High-Priority Overlays:** `surface-bright` with 80% opacity and a 20px backdrop-blur.

### The "Glass & Gradient" Rule
To avoid a flat "Bootstrap" appearance, use **Glassmorphism** for floating action buttons or navigation bars. Apply `surface_container_highest` at 70% opacity with a `backdrop-filter: blur(12px)`.
*   **Signature Textures:** For primary CTAs, use a subtle linear gradient (135°) from `primary` (`primary_color_hex`) to `primary_dim` (#305d2a). This provides a "weighted" feel that feels intentional rather than default.

---

## 3. Typography: Editorial Authority

We use **Manrope** (`headline_font`, `body_font`, `label_font`) across the entire system. Its geometric yet humanist qualities provide the perfect balance between "Professional" and "Friendly."

*   **Display (lg/md/sm):** Reserved for "Milestone" tracking moments. Use `display-md` (2.75rem) with a negative letter-spacing (-0.02em) to create an editorial headline look.
*   **Headline (lg/md/sm):** Used for section titles. Pair `headline-sm` (1.5rem) with `on_surface_variant` (#5a6156) for a sophisticated, low-contrast "subtle authority."
*   **Title (lg/md/sm):** The workhorse for card headers. `title-md` (1.125rem) should always use a Semi-Bold weight to ensure the "Organized" pillar of the brand is met.
*   **Body & Labels:** `body-md` (0.875rem) is the standard for user data. Keep line heights generous (1.6) to ensure the "Clean" aesthetic remains readable even with dense tracking logs.

---

## 4. Elevation & Depth: Tonal Layering

Traditional drop shadows are too "digital." We mimic natural ambient light.

*   **The Layering Principle:** Place a `surface-container-lowest` card (Pure White) on top of a `surface-container` (#ebefe4) background. The 2-3% shift in brightness is enough for the human eye to perceive a "lift" without a single line being drawn.
*   **Ambient Shadows:** For "Floating" elements (e.g., a tracking Modal), use an ultra-diffused shadow: `box-shadow: 0 20px 40px rgba(46, 52, 43, 0.06)`. The color is a tinted version of `on_surface`, never pure black.
*   **The Ghost Border:** If a form field requires a container, use the `outline-variant` (#adb4a7) at **15% opacity**. It should be felt, not seen.

---

## 5. Components

### Cards & Modules
*   **Radius:** Always use `xl` (1.5rem) for main containers and `md` (0.75rem) for internal nested elements. This translates to `roundedness: 3` for maximum, pill-shaped corners.
*   **Separation:** **Forbid divider lines.** Use 24px or 32px of vertical whitespace. If separation is critical, use a `surface-variant` horizontal rule that spans only 60% of the card width, centered, at 30% opacity.

### Buttons
*   **Primary:** `primary` (`primary_color_hex`) background with `on_primary` (#ebffe0) text. Shape: `full` (pill).
*   **Secondary:** `secondary_container` (#cde7ed) background. No border. This provides a "soft" alternative for secondary tracking actions.
*   **Tertiary:** Text-only using `primary` color, but with a 2px `primary_container` underline that only appears on hover.

### Input Fields
*   **Style:** Minimalist. No background fill. Only a bottom border using `outline_variant` at 20%. When focused, the border transitions to `primary` (`primary_color_hex`) at 2px height.

### Signature Component: The "Progress Bloom"
Instead of a standard linear progress bar, use a soft, thick-stroke circular gauge using `secondary` and `secondary_fixed_dim`. It feels more organic and less like a "deadline."

---

## 6. Do’s and Don'ts

### Do
*   **DO** use "Asymmetric Padding." Give more top padding (e.g., 48px) than side padding (24px) in modules to create an editorial, airy feel. This aligns with `spacing: 3`.
*   **DO** use `tertiary` (`tertiary_color_hex`) for "Insight" or "Tip" cards. It provides a warm, sunny contrast to the cooler blues and greens, signaling a "Friendly" intervention.
*   **DO** ensure all touch targets are a minimum of 44px, even if the visual element (like a small tracking dot) is smaller.

### Don't
*   **DON'T** use pure black (#000000) for text. Use `on_surface` (#2e342b) to keep the contrast high but the "vibe" soft.
*   **DON'T** use the `DEFAULT` (0.5rem) corner radius for large cards; it feels "dated/standard." Always lean toward `lg` or `xl`, which corresponds to `roundedness: 3`.
*   **DON'T** use 100% opaque `outline` colors for borders. It creates a "boxed-in" feeling that contradicts the "Friendly" aesthetic.