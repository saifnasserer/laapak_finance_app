# Laapak Style Guide

> **Inherited from:** `guidelines/design.md` & `lib/theme/app_theme.dart`

This guide provides the technical specifications for implementing the Laapak Client App design. Use these constants and patterns to ensure consistency.

---

## 1. Colors (`LaapakColors`)

| Token | Hex | Usage |
|-------|-----|-------|
| **Primary Gradient Start** | `#00C853` | Main Brand Color, Button Start |
| **Primary Gradient End** | `#00E676` | Button End |
| **Solid Green** | `#00C853` | Success, Active Icon, Focused Border |
| **Background** | `#FFFFFF` | Page Background |
| **Surface Variant** | `#F5F5F5` | **Input Fields**, Secondary Backgrounds |
| **Text Primary** | `#2C2C2C` | Headings, Body Text |
| **Text Secondary** | `#6B6B6B` | Hints, Labels, Icons |
| **Error** | `#D32F2F` | Validation Errors |

---

## 2. Shapes & Radius (`Responsive`)

Consistency in corner radius is key to the "Friendly & Modern" feel.

### Pill Shape (Buttons & Inputs)
*   **Radius**: `30.0` (or `Responsive.buttonRadius`)
*   **Usage**:
    *   Primary Buttons (`ElevatedButton`)
    *   Text Fields (`TextFormField` container)
    *   Status Chips (`Chip`)

### Card Shape (Containers)
*   **Radius**: `16.0` (or `Responsive.cardRadius`)
*   **Usage**:
    *   Content Cards
    *   Dialogs
    *   Bottom Sheets
    *   Image Containers

---

## 3. Typography (`LaapakTypography`)

**Font Family**: `Noto Sans Arabic` (Arabic) / `BDO Grotesk` (English)

| Style | Weight | Size (approx) | Usage |
|-------|--------|---------------|-------|
| **Headline Medium** | Bold (700) | 24-28px | Page Titles (e.g., "اهلاً بيك") |
| **Title Medium** | SemiBold (600)| 18-20px | Section Headers |
| **Body Large** | Medium (500) | 16px | Input Text, Main Content |
| **Body Medium** | Regular (400)| 14px | Description, Hints |
| **Button** | SemiBold (600)| 16px | CTA Text |

---

## 4. Component Patterns

### A. Primary Button (`LoadingButton`)
The primary call-to-action on any screen.
*   **Container**: Height `56px`, Width `double.infinity`.
*   **Decor**: `LaapakColors.laapakGreenGradient`.
*   **Shape**: Rounded `30px` (Pill).
*   **Text**: White, Center aligned.
*   **Loader**: White `CircularProgressIndicator`.

```dart
Container(
  height: 56,
  decoration: BoxDecoration(
    gradient: LaapakColors.laapakGreenGradient,
    borderRadius: BorderRadius.circular(Responsive.buttonRadius),
  ),
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent, // Important for gradient
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.buttonRadius)),
    ),
    // ...
  ),
)
```

### B. Minimal Input Field (`_buildMinimalTextField`)
Clean, filled inputs that focus with color.
*   **Fill**: `#F5F5F5` (`LaapakColors.surfaceVariant`).
*   **Border (Idle)**: None / Transparent.
*   **Border (Focus)**: Primary Color (`#00C853`), `1.5` width.
*   **Icon**: Leading icon (Primary when focused, Secondary otherwise).
*   **Validation**: Trailing `check_circle` (Success) or `cancel` (Error).

```dart
Container(
  decoration: BoxDecoration(
    color: Color(0xFFF5F5F5),
    borderRadius: BorderRadius.circular(Responsive.buttonRadius),
    border: Border.all(
      color: isFocused ? LaapakColors.primary : Colors.transparent,
      width: 1.5,
    ),
  ),
  child: TextFormField(...),
)
```

### C. Standard Header
Used in Auth and primitive screens.
*   **Logo**: Wrapped in `Container` with `color: primary.withOpacity(0.1)` and `shape: BoxShape.circle`.
*   **Title**: `HeadlineMedium`, Bold.
*   **Subtitle**: `BodyLarge`, TextSecondary.

---

## 5. Spacing
*   **Screen Padding**: `24.0` (Horizontal).
*   **Section Gap**: `32.0` or `48.0`.
*   **Item Gap**: `16.0`.

---
*Created automatically from current codebase state.*
