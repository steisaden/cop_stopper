---
page: live-recording
---
# Live Recording Session - CopStopper Redesign

Design a mobile app live recording screen for a police encounter recording app. This is the active recording interface shown while recording is in progress.

**VISUAL STYLE:**
- Minimalist dark-first UI
- Layered glassmorphism with stacked translucent surfaces
- Backdrop blur with subtle borders
- Soft realistic shadows with gentle highlight sheen (top-left gradient)
- Maximum 3 glass layers per region

**GLASS DEPTH SYSTEM:**
- Base Glass: Primary containers, stronger blur (20px), soft wide shadow (rgba(0,0,0,0.3))
- Inset Glass: Inner panels, reduced blur (10px), tighter shadow
- Floating Glass: Buttons/chips/badges, minimal blur, crisp border #ffffff20, subtle elevation

**COLOR PALETTE:**
- Primary accent: #197fe6
- Recording active: #e63946 (red glow)
- Background: #0a0a0f (near black)
- Surface glass base: rgba(255,255,255,0.05)
- Surface glass border: rgba(255,255,255,0.1)
- Text primary: #ffffff
- Text secondary: #8b8b99

**TYPOGRAPHY:**
- Font: Inter
- Headings: Bold, well-spaced
- Body: Regular, high legibility

**SPACING:**
- Generous padding (16-24px)
- Clear visual hierarchy
- Large touch targets (48px minimum)
- Designed for one-handed use

**Page Structure:**
1. **Top Bar** - Frosted glass with:
   - Recording indicator (pulsing red dot)
   - Timer showing elapsed time (00:00:00 format, large and bold)
   - Minimize/background button
2. **Waveform Strip** - Inset Glass panel with:
   - Live audio waveform visualization (minimal, clean lines)
   - Amplitude indicator
3. **Live Transcript Panel** - Base Glass container with:
   - Scrolling real-time transcript text
   - Timestamps on the left margin
   - Auto-scroll to latest text
   - Semi-transparent scrollbar
4. **Quick Legal Phrase Chips** - Row of Floating Glass chips:
   - "Am I being detained?"
   - "I do not consent to searches"
   - "I invoke my right to remain silent"
   - Scrollable horizontally
5. **Recording Controls** - Bottom Floating Glass panel:
   - Large STOP button (red accent with glow)
   - Pause button
   - Mark highlight button (flag important moments)
6. **Emergency Alert** - Floating Glass button in corner:
   - Alert trusted contacts icon
   - Subtle but accessible

**Interaction Notes:**
- Recording indicator pulses with subtle glow animation
- Stop button has prominent red glow (#e63946)
- Legal chips tap to speak aloud (visual feedback on tap)
- Transitions: 150-220ms ease-out
- Waveform animates smoothly with audio input
