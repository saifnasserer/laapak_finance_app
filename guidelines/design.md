تمام — ده **نفس الدوك** لكن متحوّل بالكامل ليخدم **Laapak Finance App**
من غير ما نلمس **الستايل، التون، الإحساس، أو الفلسفة** نهائيًا.
كل اللي اتغير هو *الوظيفة والسياق* 👇

---

# Laapak Finance App

## UI / UX Design Brief

---

## 1. Design Vision

The **Laapak Finance App** should feel **calm, intelligent, and trustworthy**, reflecting financial clarity and operational control with a strong local identity.

The application is **Arabic-first**, respecting RTL reading flow, clarity, and familiarity for daily business use.

The overall interaction feel is **Modern & Minimalist** (inspired by DeepSeek UI), prioritizing:

* **Calm financial workflows**
* **Zero visual noise**
* **Data-first presentation**
* **Smooth, reassuring motion**

> The app must feel **professional, reliable, and confidence-building**, suitable for daily financial decision-making.

---

## 2. Core Design Principles

### 2.1 Clarity Over Decoration

* Every screen answers **one financial question**.
* White space improves readability of numbers and summaries.
* **Pill-shaped elements** soften complex financial data.

### 2.2 Calm Confidence

* No alarming colors unless required (errors only).
* Balanced contrast for long data review sessions.
* **Subtle gradients** only for primary financial actions.

### 2.3 Guided Financial Flow

* The UI gently guides users through:

  * Tracking income
  * Recording expenses
  * Reviewing profit & loss
* Inputs and actions use **high border radius (Pill shape)** to feel approachable, not intimidating.

---

## 3. Visual Style

### 3.1 Color System (Official Laapak Brand Colors)

This system strictly follows `LaapakColors`.

#### Primary Brand Color

**Laapak Green Gradient** (Core Identity)

* **Start**: `#00C853`
* **End**: `#00E676`
* **Usage**:

  * Primary CTAs (Add Income, Save Expense)
  * Positive balances
  * Confirmed financial actions
* **Style**: Vertical or subtle diagonal gradient.

#### Base Colors

* **White** (`#FFFFFF`): Main background.
* **Off-White / Surface Variant** (`#F5F5F5`): Tables, input fields, grouped financial data.
* **Black** (`#000000` / `#1A1A1A`): Dark mode backgrounds, totals emphasis.

#### Neutral System

* **Dark Gray** (`#2C2C2C`): Main numbers & labels.
* **Medium Gray** (`#6B6B6B`): Secondary values, dates, notes.
* **Light Gray** (`#E0E0E0`): Separators, borders, dividers.

#### Functional Colors (Finance-Oriented)

* **Success** (`#00C853`): Profits, paid, confirmed.
* **Warning** (`#FFB300`): Pending, due soon.
* **Error** (`#D32F2F`): Losses, failed actions.
* **Info** (`#2196F3`): Reports, summaries, neutral insights.

---

### 3.2 Typography

**Headings & Body (English):** `BDO Grotesk`
**Headings & Body (Arabic):** `Noto Sans Arabic`

* **Primary Text**: Dark Gray (`#2C2C2C`).
* **Secondary Text**: Medium Gray (`#6B6B6B`).
* **Weights**:

  * Regular → transaction details
  * Medium → labels & buttons
  * Semi-Bold → section headers
  * Bold → totals, profit/loss highlights

---

## 4. Components & Layout

### 4.1 Buttons (Primary Financial Actions)

* **Shape**: **Pill-shaped** (`~30px radius`).
* **Color**: **Laapak Green Gradient**.
* **Text**: White, Medium/Semi-Bold.
* **Elevation**: Flat or very subtle.
* **Behavior**: Smooth scale + opacity feedback.

**Examples**

* إضافة إيراد
* تسجيل مصروف
* حفظ العملية

---

### 4.2 Input Fields

* **Shape**: **Pill-shaped**
* **Background**: `#F5F5F5`
* **Border States**:

  * Default: None
  * Focused: Green (`#00C853`)
  * Error: Red (`#D32F2F`)
* **Optimized for**:

  * Numeric entry
  * Currency clarity
  * Quick daily use

---

### 4.3 Cards (Financial Blocks)

* **Shape**: Rounded (`12–16px`)
* **Background**: White
* **Usage**:

  * Daily summary
  * Monthly totals
  * Profit/Loss snapshot
* **Padding**: Generous (`16px+`)
* **Style**: Clean, readable, non-distracting

---

## 5. Interaction Design

### 5.1 Motion

* **Transitions**: Fade + Slide (soft, predictable).
* **Purpose**:

  * Reinforce financial confirmation
  * Reduce anxiety when saving data
* **Haptics**:

  * Medium impact on successful save
  * Soft warning vibration on errors

---

### 5.2 Microcopy (Finance Tone)

* **Tone**: Calm, professional, reassuring.
* **Arabic-first & business-native**

**Examples**

* "ملخص النهار"
* "كل الأرقام تحت السيطرة"
* "تم الحفظ بنجاح ✅"
* "راجع الأرقام قبل المتابعة"

---

## 6. Iconography

* **Style**: Rounded, Simple, Outlined (Material Symbols Rounded).
* **Usage**:

  * Wallets
  * Charts
  * Income / Expense indicators
* **Color**:

  * Neutral by default
  * Green / Red only when meaningful

---

## 7. Accessibility & Usability

* **RTL**: Mandatory & native.
* **Contrast**: WCAG AA compliant for long financial sessions.
* **Touch Targets**: ≥ 44x44px.
* **Readability**: Numbers always prioritized over decoration.

---

### Final Note

> The **Laapak Finance App** should make finance feel **clear, calm, and under control** —
> not stressful, not noisy, and never overwhelming.

لو حابب، الخطوة الجاية أقدر:

* أعمل **Screen Structure** (Dashboard / Income / Expenses / Reports)
* أو **Component mapping** للـ Flutter
* أو **Finance UX flow** يومي / شهري

قولّي تحب نكمل على إيه 👌
