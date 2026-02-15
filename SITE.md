# CopStopper Site Vision

> A premium Flutter mobile app for documenting police encounters with calm, authoritative, and trustworthy design.

## Section 1: Vision

CopStopper is a police encounter recording app optimized for high-stress real-world use. The redesign focuses on:

- **Minimalist dark-first UI** with subtle glassmorphism
- **Layered glass depth system** (Base, Inset, Floating)
- **Restrained micro-animations** (150-220ms ease-out)
- **One-handed, stress-friendly interaction**
- **Calm, authoritative visual language**

## Section 2: Stitch Project

- **Project ID**: `13517505834194279732`
- **Project Name**: copstopredesign
- **Device Type**: MOBILE
- **Theme**: Dark mode, Inter font, 8px radius

## Section 3: Design System Summary

### Glass Depth System

| Variant | Usage | Blur | Shadow |
|---------|-------|------|--------|
| **Base Glass** | Primary containers | Strong blur (20px) | Soft wide shadow |
| **Inset Glass** | Inner panels, grouped content | Reduced blur (10px) | Tighter shadow |
| **Floating Glass** | Chips, buttons, badges | Minimal/none | Crisp border, subtle elevation |

### Color Tokens

- **Primary**: `#197fe6` (Blue accent)
- **Background**: `#0a0a0f` (Deep dark mode base)
- **Surface**: `rgba(255,255,255,0.05)` (Translucent glass)
- **Border**: `rgba(255,255,255,0.1)` 
- **Text Primary**: `#ffffff`
- **Text Secondary**: `#8b8b99`
- **Recording Active**: `#e63946` (Red glow)
- **Success/Secure**: `#22c55e` (Green)
- **AI Accent**: `#a855f7` (Purple)

### Motion Tokens

- **Standard Duration**: 150-220ms
- **Easing**: ease-out
- **Entry**: Fade + 8px vertical shift
- **Recording Active**: Subtle pulse
- **Interaction**: scale(1.02) or translateY(-2px)

## Section 4: Sitemap (Generated Pages)

- [x] Main Dashboard ✓ (Screen ID: 9c60eaa543714154b7d8bed45386f0a1)
- [x] Live Recording Session ✓ (Screen ID: f3902d23d3ef4cd98c634f6f7338250b)
- [x] Session Summary ✓ (Screen ID: 41a28f264ca34dd6ad51d6bcf4ebc09d)
- [x] Legal Advice Chat ✓ (Screen ID: c557d851083942aa9253824db3668adf)
- [x] Officer Search ✓ (Screen ID: 09ac746313674ad5a1f35593f44f3aa7)
- [x] Document Vault ✓ (Screen ID: 8bda2229241a44619e665df8e6f5e92c)
- [x] App Permissions Onboarding ✓ (Screen ID: 0a8ea870e19e4d3ebad895a860fc8d9d)
- [x] Collaborative Monitoring ✓ (Screen ID: 65a3678d728e4ea3b02300664593f5bc)
- [x] Recording History ✓ (Screen ID: a12857fe3bce43569b6ac3b179fa2d52)
- [x] App Settings ✓ (Screen ID: e038093c08f04ac0af9a0654a75482f8)

## Section 5: Roadmap (Completed ✓)

All 10 screens have been redesigned with the glassmorphism design system.

## Section 6: Design System Notes for Stitch Generation

**ALWAYS INCLUDE THIS BLOCK IN PROMPTS:**

```
VISUAL STYLE:
- Minimalist dark-first UI
- Layered glassmorphism with stacked translucent surfaces
- Backdrop blur with subtle borders
- Soft realistic shadows with gentle highlight sheen (top-left gradient)
- Maximum 3 glass layers per region

GLASS DEPTH SYSTEM:
- Base Glass: Primary containers, stronger blur (20px), soft wide shadow (rgba(0,0,0,0.3))
- Inset Glass: Inner panels, reduced blur (10px), tighter shadow
- Floating Glass: Buttons/chips/badges, minimal blur, crisp border #ffffff20, subtle elevation

COLOR PALETTE:
- Primary accent: #197fe6
- Background: #0a0a0f (near black)
- Surface glass base: rgba(255,255,255,0.05)
- Surface glass border: rgba(255,255,255,0.1)
- Text primary: #ffffff
- Text secondary: #8b8b99

MOTION:
- Transitions: 150-220ms ease-out
- Entry: Fade with 8px vertical shift
- Interaction: scale(1.02) or translateY(-2px) on hover/press
- Recording pulse: subtle glow animation

TYPOGRAPHY:
- Font: Inter
- Headings: Bold, well-spaced
- Body: Regular, high legibility

SPACING:
- Generous padding (16-24px)
- Clear visual hierarchy
- Large touch targets (48px minimum)
- Designed for one-handed use
```
