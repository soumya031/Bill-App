---
name: Core Ledger
colors:
  surface: '#f8f9ff'
  surface-dim: '#ccdbf3'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e6eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d5e3fc'
  on-surface: '#0d1c2e'
  on-surface-variant: '#464652'
  inverse-surface: '#233144'
  inverse-on-surface: '#eaf1ff'
  outline: '#777683'
  outline-variant: '#c7c5d4'
  surface-tint: '#4f54b4'
  primary: '#15157d'
  on-primary: '#ffffff'
  primary-container: '#2e3192'
  on-primary-container: '#9da1ff'
  inverse-primary: '#c0c1ff'
  secondary: '#006c4a'
  on-secondary: '#ffffff'
  secondary-container: '#82f5c1'
  on-secondary-container: '#00714e'
  tertiary: '#3c2300'
  on-tertiary: '#ffffff'
  tertiary-container: '#5a3700'
  on-tertiary-container: '#ec9700'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e1e0ff'
  primary-fixed-dim: '#c0c1ff'
  on-primary-fixed: '#04006d'
  on-primary-fixed-variant: '#373a9b'
  secondary-fixed: '#85f8c4'
  secondary-fixed-dim: '#68dba9'
  on-secondary-fixed: '#002114'
  on-secondary-fixed-variant: '#005137'
  tertiary-fixed: '#ffddb8'
  tertiary-fixed-dim: '#ffb95f'
  on-tertiary-fixed: '#2a1700'
  on-tertiary-fixed-variant: '#653e00'
  background: '#f8f9ff'
  on-background: '#0d1c2e'
  surface-variant: '#d5e3fc'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 57px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  headline-sm:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-lg:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '500'
    lineHeight: 28px
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
    letterSpacing: 0.01em
  title-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-md:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
  label-sm:
    fontFamily: Inter
    fontSize: 10px
    fontWeight: '500'
    lineHeight: 14px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 34px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 20px
  xxl: 32px
  margin-mobile: 16px
  margin-tablet: 24px
  gutter: 16px
---

## Brand & Style

This design system is engineered for efficiency, precision, and institutional trust. It targets business owners and financial operators who require a high-density, high-speed interface that remains visually calm under heavy data loads.

The aesthetic follows a **Modern Corporate** approach with **Minimalist** influences. It prioritizes clarity over decoration, utilizing generous white space, a disciplined color palette, and subtle depth to guide the user's eye toward critical financial metrics. The interface should feel like a high-performance instrument—unobtrusive, reliable, and sophisticated.

## Colors

The color palette is anchored by a deep Navy primary, conveying stability and authority. 

- **Primary (#2E3192):** Used for key actions, active navigation states, and brand reinforcement.
- **Success (#059669):** A deep Emerald specifically chosen for high legibility in financial contexts (e.g., positive cash flow).
- **Warning (#F59E0B):** A balanced Amber for pending states and cautionary flags.
- **Error (#DC2626):** A sharp Crimson for overdue invoices or critical system failures.
- **Surface & Background:** Utilize a "Slate" neutral scale. Backgrounds should be pure white (#FFFFFF), with surface containers using subtle off-whites (#F8FAFC) to create hierarchical separation.

## Typography

This system uses **Inter** for its exceptional legibility and neutral, professional character. 

**Financial Data Rules:**
- All currency and numerical data must use **tabular lining figures** (tnum) to ensure columns of numbers align vertically for easy comparison.
- Use `Title Large` for secondary metrics and `Headline Medium` for primary account balances.

**Hierarchy:**
- Headlines should be tight and impactful with slight negative letter spacing.
- Labels are frequently used in uppercase with tracking (0.05em) for category headers and metadata tags.

## Layout & Spacing

The design system utilizes a strict **4px baseline grid** with a primary spacing rhythm of **12px, 16px, and 20px**. 

**Layout Philosophy:**
- **Fluid Grid:** Content adapts to screen width with fixed side margins.
- **Touch Targets:** A minimum height/width of 48dp is mandatory for all interactive elements to ensure high-speed operation without errors.
- **Vertical Rhythm:** Group related items using 12px (md); separate distinct sections using 20px (xl) or 32px (xxl).
- **Mobile Margins:** Use 16px horizontal margins for standard views. For data-heavy tables, this may reduce to 12px to maximize horizontal real estate.

## Elevation & Depth

To maintain a "clean" fintech aesthetic, this design system avoids heavy borders and instead uses **Tonal Layering** and **Ambient Shadows**.

- **Level 0 (Background):** Pure White (#FFFFFF).
- **Level 1 (Cards/Surfaces):** Use a subtle shadow (Blur: 8px, Y: 2px, Opacity: 4% Black) to lift content.
- **Level 2 (Modals/Bottom Sheets):** Higher elevation (Blur: 16px, Y: 4px, Opacity: 8% Black).
- **Separators:** Use 1px hairlines in #E2E8F0 for list items. Avoid borders on cards unless they are in a "Selected" state, in which case use a 2px stroke of the primary color.

## Shapes

The shape language is sophisticated and approachable, moving away from sharp industrial corners toward a more modern, softened feel.

- **Standard Components (Buttons, Inputs):** 8px radius (rounded-md).
- **Large Containers (Cards, Bottom Sheets):** 12px to 16px radius (rounded-lg/xl).
- **Status Chips:** Full pill-shape (100px) to distinguish them from interactive buttons.

## Components

### Buttons & Inputs
- **Primary Button:** Solid #2E3192 background, white text. High-contrast, no shadow, 48dp height.
- **Secondary Button:** White background, 1px #E2E8F0 border, primary color text.
- **Input Fields:** 56dp height with floating labels (Material 3 style). Use a subtle #F8FAFC fill to make them feel "recessed."

### Financial Status Chips
- **Paid:** Success Green background (10% opacity), Success Green text.
- **Overdue:** Error Red background (10% opacity), Error Red text.
- **Pending:** Warning Amber background (10% opacity), Warning Amber text.

### Feedback & Sync
- **Sync Status:** Small 24dp horizontal badge in the app bar or footer.
  - *Synced:* Check icon + "Synced" in secondary text color.
  - *Offline:* Cloud-off icon + "Offline" in #64748B.
- **Bottom Sheets:** Used for all contextual workflows (e.g., adding a transaction). Must include a 4px wide "grabber" handle at the top.
- **Cards:** White background, 8px radius, subtle 1px gray-100 border or level-1 shadow.