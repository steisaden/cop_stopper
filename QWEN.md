# Qwen Development Guide

This guide documents the setup, troubleshooting, and workflow rules for the Cop Stopper project.

---

## 📑 Table of Contents

1. [Building and Running](#building-and-running)
2. [Flutter Development Setup](#flutter-development-setup)
   - [Docker-Based Development (Recommended)](#docker-based-development-recommended)
   - [Local Development (Alternative)](#local-development-alternative)
   - [Troubleshooting](#flutter-development-troubleshooting)
   - [Quick Fix Table](#quick-fix-table)
3. [Backend Development (Node.js)](#backend-development-nodejs)
4. [Full Development Workflow](#full-development-workflow)
5. [Docker Configuration Details](#docker-configuration-details)
6. [Writing Tests](#writing-tests)
7. [Collaborative Workflow with Kiro](#collaborative-workflow-with-kiro)
8. [Anti-Patterns and Best Practices](#common-anti-patterns-and-solutions)
9. [Debugging Methodology](#debugging-methodology-the-kiro-approach)
10. [Loop Detection and Breaking](#loop-detection-and-breaking-strategies)
11. [Critical Quality Standards](#critical-quality-standards)
12. [MCP-Driven Development and Automation](#mcp-driven-development-and-automation)
   - [MCP Priority Ladder](#mcp-priority-ladder)
   - [Problem Handling and Escalation Rules](#problem-handling-and-escalation-rules)
   - [Deterministic Edit Protocol](#deterministic-edit-protocol)
   - [Parallel Context Gathering](#parallel-context-gathering)
   - [Task Closure Checklist](#task-closure-checklist)

---

## Building and Running

This project is a mobile application built with Flutter/Dart (iOS and Android) with a Node.js backend. Development uses Docker for consistency.

---

## Flutter Development Setup

### Docker-Based Development (Recommended)

- Requires **Docker & Docker Compose**
- No local Flutter installation needed
- Flutter app lives in `/mobile`

**Key Commands:**

```bash
docker-compose run --rm app flutter pub get        # Install deps
docker-compose up                                  # Run app (web dev)
docker-compose run --rm app flutter test           # Run tests
docker-compose run --rm app flutter analyze        # Lint/analyze
docker-compose run --rm app flutter clean          # Clean build
docker-compose run --rm app flutter doctor         # Check env
```

### Local Development (Alternative)

If you want local Flutter SDK development:

```bash
flutter doctor
cd mobile
flutter pub get
flutter run -d ios
flutter run -d android
flutter build apk
flutter build ios
flutter build appbundle
```

---

## Flutter Development Troubleshooting

### Common Issues & Fixes

| Problem | Cause | Fix |
|---------|-------|-----|
| ❌ `flutter` not found | You’re running locally, but Flutter is only in Docker | Use `docker-compose run --rm app flutter ...` |
| ❌ `No pubspec.yaml found` | Wrong working directory | Always run from project root (`docker-compose` handles working_dir) |
| ❌ `Matrix4` undefined / `vector_math` missing | Corrupt Docker Flutter environment | Run **Nuclear Reset** (see below) |
| ❌ `build_runner` fails | Dart SDK 2.18.6 incompatible with new packages | Downgrade deps (done in pubspec) OR update Dockerfile to newer Flutter |
| ❌ Tests fail but app works in browser | Test environment mismatch | Use [Debugging Methodology](#debugging-methodology-the-kiro-approach) |

### Decision Tree: Flutter Commands

- ❌ Running `flutter pub get` locally → **Wrong**. Must use Docker.  
- ❌ `Could not find pubspec.yaml` → Ensure `docker-compose.yml` exists in root.  
- ❌ Build fails with missing `vector_math`, `characters` → **Reset Docker env**.  
- ❌ build_runner fails → Either **downgrade packages** or **upgrade Docker image**.  

### Nuclear Reset (Complete Docker Rebuild)

```bash
docker-compose down --volumes --remove-orphans
docker system prune -f
docker volume prune -f
docker-compose build --no-cache app
docker-compose run --rm app flutter doctor
docker-compose run --rm app flutter pub get --verbose
```

---

## Backend Development (Node.js)

```bash
npm install
npm run dev
npm test
npm run build

# With Docker
npm run docker:dev
npm run docker:prod
npm run docker:test
npm run docker:clean
```

---

## Full Development Workflow

Before pushing code:

### Flutter
```bash
docker-compose run --rm app flutter analyze
docker-compose run --rm app flutter test
docker-compose run --rm app flutter test integration_test/
```

### Backend
```bash
npm run lint
npm run test
npm run test:e2e
npm run build
```

---

## Docker Configuration Details

- **Dockerfile**: Multi-stage Next.js prod build  
- **Dockerfile.dev**: Dev env with hot reload  
- **docker-compose.yml**: Service orchestration  
- **docker-scripts.sh**: Helper scripts  

See `README-DOCKER.md` for deep details.

---

## Writing Tests

- **Flutter**: Dart’s `test` and `integration_test`
- **Backend**: Jest + Playwright

### Best Practices
- Prefer **robust assertions** (`findsWidgets` > `findsNWidgets(3)`)  
- Handle **Rich Text** with `find.textContaining`  
- Focus on **UX, not internal error messages**  
- Always **mock platform services** (recorder, location, HTTP)

---

## Collaborative Workflow with Kiro

- Follow `.kiro/DEVELOPMENT_WORKFLOW.md`  
- Specs live in `.kiro/specs/`  
- Always update `tasks.md` and `CHANGELOG.md` after completing tasks

---

## Common Anti-Patterns and Solutions

### Wrong
```dart
await audioRecorder.start();
await audioRecorder.stop(); // immediate
```

### Correct
```dart
await audioRecorder.start();
while (!await audioRecorder.isRecording()) {
  await Future.delayed(Duration(milliseconds: 100));
}
await audioRecorder.stop();
```

Other pitfalls covered: poor persistence, no error handling, duplicate services.

---

## Debugging Methodology: The Kiro Approach

### Golden Rules
1. **Data Verification First** → 90% of mysterious test failures are mismatched test data.  
2. **30-30-30 Rule** → 30min inspect data, 30min check env differences, 30min simplify test.  
3. **3-Attempt Circuit Breaker** → After 3 failed approaches, stop and document.

### Example: Timezone Bug
- Input: `new Date('2025-08-26T00:00:00.000Z')`
- Expected: `"2025-08-26"`  
- Actual in test: `"2025-08-25"`  
- ✅ Fix: use formatted key dynamically (`format(date, 'yyyy-MM-dd')`).

### Chrome DevTools Debugging Protocol

**For Flutter Web Apps:**

1. **Open DevTools**: F12 in browser while app is running
2. **Check Console**: Look for Flutter exceptions and warnings
3. **Test Navigation**: Click through all tabs to identify broken screens
4. **Screenshot Issues**: Take screenshots of error screens for documentation
5. **Network Tab**: Check for failed API calls or resource loading issues

**Common Console Error Patterns:**
```
Error: Could not find Provider<XBloc> → BLoC registration issue
dependOnInheritedWidget...before initState → Widget lifecycle issue  
RenderFlex overflowed by X pixels → Layout overflow issue
Assertion failed: framework.dart → Widget tree structure issue
```

**Debugging Workflow:**
1. Load app in browser (`flutter run -d chrome` or `http://localhost:8080`)
2. Open Chrome DevTools (F12)
3. Navigate through all screens systematically
4. Document any console errors or visual issues
5. Fix errors in order of severity (crashes > layout > warnings)
6. Re-test after each fix to ensure no regressions

---

## Loop Detection and Breaking Strategies

**Stop if:**
- Same test fails after 3 fixes  
- App works but test still fails  
- >2 hours spent debugging a single test  

**Then:**
- Document in progress file  
- Move on, confirm UX works in browser/device

---

## Critical Quality Standards

🚨 **Never**
- Use `any` types  
- Submit code that doesn’t compile  
- Duplicate implementations  
- Mock APIs incorrectly

✅ **Always**
- Validate environment variables  
- Add error handling + retry logic  
- Ensure tests actually pass  
- Integrate with existing systems

### Enhanced Quality Standards (Post-Phase 2 Assessment)

## 🚨 CRITICAL: Phase 2 Assessment Results

**Qwen's Phase 2 Implementation Grade: D+ (35%)**

**Key Failures Identified:**
- ❌ Incomplete implementations that don't compile (record_screen.dart cuts off mid-function)
- ❌ Claims "pixel-perfect" implementation without visual verification
- ❌ No evidence of `flutter analyze` or browser testing
- ❌ Only attempted 2 screens out of 10+ required Phase 2 features
- ❌ Documentation claims don't match actual implementation approach

**What Worked Well:**
- ✅ Excellent design system foundation (AppColors, AppSpacing, components)
- ✅ Good architectural understanding and BLoC integration
- ✅ Comprehensive color tokens and spacing system
- ✅ Clean component structure (ShadcnCard, FigmaBadge)

## 🔧 **MANDATORY Compilation-First Protocol**
- **NEVER** mark any task complete without running `flutter analyze` successfully
- **NEVER** submit partial implementations that cut off mid-function
- **ALWAYS** declare all variables before use (theme, colorScheme, etc.)
- **ALWAYS** verify all imports and component dependencies exist
- **PENALTY**: Any task marked complete with compilation errors results in automatic task failure

## 🎨 **Design Implementation Standards**
- **CONSISTENCY**: Choose either theme.colorScheme OR hardcoded Figma colors - don't mix approaches
- **VERIFICATION**: Must test in browser and take screenshots before claiming "pixel-perfect"
- **INCREMENTAL**: Implement and test each component individually before integration
- **THEMING**: Test both light and dark themes for every UI change

## 🐛 **Error-First Debugging Protocol**
- Fix compilation errors before ANY functionality work
- Test individual components in isolation before integration
- Use systematic variable declaration checking
- Implement proper error handling for all user interactions
- Document any errors found and their resolution in CHANGELOG.md

### MANDATORY Runtime Verification Protocol

🚀 **ZERO TOLERANCE - Before Marking Any Task Complete:**

1. **Compilation Check**: Run `flutter analyze` - must pass with ZERO errors or warnings
2. **Runtime Test**: Load app in browser using `docker-compose up` and verify functionality works
3. **Console Check**: Open browser DevTools - must have ZERO Flutter exceptions or warnings
4. **Navigation Test**: Click through ALL navigation tabs - must work without crashes
5. **Layout Check**: Ensure ZERO overflow warnings (no yellow/black stripes)
6. **BLoC Integration**: Verify new BLoCs are registered in service_locator.dart and accessible
7. **Visual Verification**: Take screenshots and compare to Figma designs if claiming design compliance
8. **Complete Implementation**: Ensure all functions/widgets are complete - no cut-off implementations

**AUTOMATIC TASK FAILURE CONDITIONS:**
- Any compilation errors when running `flutter analyze`
- Any Flutter exceptions in browser console
- Any navigation tabs that don't work
- Any incomplete implementations (functions that cut off mid-way)
- Any claims of "completion" without browser testing evidence

### Common Flutter Error Patterns & Fixes

| Error Pattern | Root Cause | Fix |
|---------------|------------|-----|
| `Could not find Provider<XBloc>` | BLoC not registered in service locator | Add to `service_locator.dart` and main app providers |
| `dependOnInheritedWidget...before initState` | Theme access in constructor/initState | Move to `didChangeDependencies()` |
| `RenderFlex overflowed by X pixels` | Layout constraints exceeded | Wrap in `Expanded`, `Flexible`, or `SingleChildScrollView` |
| Navigation tabs not responding | NavigationBloc provider missing | Ensure NavigationBloc is provided to widget tree |
| Red error screen on tab switch | Widget lifecycle or provider issue | Check widget initialization and BLoC access |

### BLoC Integration Checklist

When creating new BLoCs:
- [ ] BLoC class implemented with proper events/states
- [ ] Service dependencies injected correctly
- [ ] Registered in `service_locator.dart`
- [ ] Added to main app BlocProvider list
- [ ] UI can access BLoC without provider errors
- [ ] Navigation to screen works without crashes

### Widget Lifecycle Best Practices

```dart
// ❌ Wrong - accessing theme in initState
@override
void initState() {
  super.initState();
  final theme = Theme.of(context); // ERROR!
}

// ✅ Correct - accessing theme in didChangeDependencies
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final theme = Theme.of(context); // Safe
}
```

### Layout Overflow Solutions

```dart
// ❌ Wrong - causes overflow
Column(
  children: [
    Widget1(),
    Widget2(),
    Widget3(), // Too many widgets, causes overflow
  ],
)

// ✅ Correct - prevents overflow
Column(
  children: [
    Widget1(),
    Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [Widget2(), Widget3()],
        ),
      ),
    ),
  ],
)
```

---

## MCP-Driven Development and Automation

Use Model Context Protocol (MCP) capabilities as the default path to complete tasks efficiently, accurately, and deterministically.

- Priority of approach
  - First: Use MCP-enabled search, memory, and automation to gather context and execute changes.
  - Second: Write targeted edits that align with existing patterns and architecture.
  - Third: If blocked, create minimal scaffolding and tests to unblock, then iterate.

- Task management discipline
  - Always consult and update the spec task list after each task or fix (tasks.md).
  - Append a concise entry to the changelog describing what changed and why (CHANGELOG.md).
  - Keep entries traceable: reference files touched, requirements addressed, and tests added.

- Code discovery before edits
  - Perform targeted repository searches to find definitions, interfaces, and usages before editing.
  - Read enough of each file to obtain complete context; avoid partial edits without understanding imports and side effects.
  - Prefer one precise edit over many small ones; batch related edits together.

- Parallelization and efficiency
  - Run multiple read-only searches in parallel (definitions, usages, imports) to form a complete picture quickly.
  - When reading files, choose ranges that cover full functions/classes and avoid overlapping reads.

- Safe editing rules
  - Follow existing conventions, naming, and error-handling patterns.
  - Never commit secrets; never log sensitive values.
  - Add imports and dependencies explicitly; verify they are already used in the codebase before introducing new ones.

- Testing and verification
  - Prefer unit tests for pure logic; add integration tests for cross-layer behavior.
  - When adding UI or workflow changes, verify locally and create or update tests accordingly.
  - Keep tests deterministic, fast, and isolated with mocks for platform services.

- Debugging methodology
  - Read the full error message; identify the first failing cause, not downstream noise.
  - Reproduce with the smallest possible case; write a regression test before the fix when practical.
  - After fixing, re-run the full suite relevant to the change.

- Documentation and artifact updates
  - When a feature is implemented or a bug is fixed, update tasks.md and CHANGELOG.md in the same session.
  - Keep QWEN.md aligned with the actual workflow; refine rules when recurring issues are detected.

- Security, privacy, and compliance
  - Respect platform permissions and background execution policies.
  - Handle user data with least privilege and clear lifecycle (creation, storage, cleanup).
  - Ensure accessibility and jurisdiction-aware behavior remain intact after changes.

- When not to proceed
  - If requirements are ambiguous or conflict with existing specs, pause and document the ambiguity.
  - Avoid speculative refactors; only change what is necessary to complete the task.

### Proactive Error Prevention

**Before Starting Any Task:**

1. **Environment Check**: Ensure `flutter analyze` passes on current codebase
2. **Baseline Test**: Load app in browser and verify current functionality works
3. **Dependency Review**: Check if task requires new BLoCs, services, or components
4. **Integration Planning**: Identify what needs to be registered/provided

**During Implementation:**

1. **Incremental Testing**: Test after each significant change
2. **Console Monitoring**: Keep browser DevTools open to catch errors immediately
3. **Pattern Following**: Use existing code patterns rather than inventing new ones
4. **Scope Limiting**: Focus on minimum viable implementation first

**Red Flags to Watch For:**

- Creating BLoCs without immediately registering them
- Accessing Theme.of(context) in constructors or initState()
- Adding widgets to Columns without considering overflow
- Implementing navigation without testing it works
- Claiming completion without browser testing
- Ignoring console warnings as "minor issues"

**Success Indicators:**

- ✅ `flutter analyze` passes
- ✅ App loads in browser without errors
- ✅ Console shows no Flutter exceptions
- ✅ All navigation tabs work
- ✅ No layout overflow warnings
- ✅ New functionality works as expected
- ✅ Existing functionality still works

### MCP Priority Ladder

1. Gather full context using repository-wide searches and targeted file reads.
2. Identify exact edit points, symbols, and dependencies before any change.
3. Execute the smallest set of edits that achieves the goal, batching related changes.
4. Validate via tests and, for UI changes, run the app and visually verify.
5. Document immediately (tasks.md, CHANGELOG.md) and link to requirements.

### Problem Handling and Escalation Rules

- Always attempt three evidence-based fixes before escalating.
- If a blocker persists:
  - Capture the precise error output and minimal reproduction steps.
  - Check environment and dependency versions against `tech.md`.
  - Perform a clean rebuild (see Nuclear Reset) if environment corruption is suspected.
  - Create a temporary guard or feature flag to unblock other workstreams where safe.
- Escalate by documenting the issue, impact, and proposed next steps in CHANGELOG under Problem Reports.

### Deterministic Edit Protocol

- Never edit without first locating all definitions and usages.
- Preserve existing public APIs unless explicitly refactoring.
- Add imports and dependency entries atomically with code edits.
- Keep edits idempotent and reversible; prefer adding over destructive changes.

### Parallel Context Gathering

- Run multiple searches simultaneously: symbols, imports, and references across layers.
- Read adjacent files together (service, interface, tests) to understand contracts.
- Prefer broad initial scans, then narrow to precise edit windows.

### Task Closure Checklist

#### **Pre-Implementation**
- [ ] Specs consulted (requirements.md, design.md, product/structure/tech.md)
- [ ] Code discovery completed (definitions/usages/imports located)
- [ ] Existing patterns and architecture understood
- [ ] **SCOPE REALISTIC**: Only attempt features that can be completed fully

#### **Implementation (ZERO TOLERANCE)**
- [ ] **COMPLETE IMPLEMENTATIONS ONLY**: No partial functions or cut-off code
- [ ] **COMPILATION VERIFIED**: `flutter analyze` passes with ZERO errors/warnings
- [ ] **VARIABLES DECLARED**: All theme, colorScheme, and other variables properly declared
- [ ] **IMPORTS VERIFIED**: All custom components and dependencies exist and are imported
- [ ] **BLOC REGISTRATION**: New BLoCs registered in service locator AND main app
- [ ] **CONSISTENT APPROACH**: Either use theme.colorScheme OR hardcoded colors, not both

#### **MANDATORY Runtime Verification**
- [ ] **DOCKER TEST**: App loads using `docker-compose up` without crashes
- [ ] **BROWSER CONSOLE**: ZERO Flutter exceptions or warnings in DevTools console
- [ ] **NAVIGATION COMPLETE**: ALL navigation tabs tested and working
- [ ] **LAYOUT VERIFIED**: ZERO overflow warnings (no yellow/black stripes)
- [ ] **FUNCTIONALITY TESTED**: All claimed features actually work in browser
- [ ] **VISUAL VERIFICATION**: Screenshots taken if claiming design compliance
- [ ] **PERFORMANCE CHECK**: No obvious performance issues or memory leaks

#### **Testing & Documentation**
- [ ] Tests added/updated and passing locally
- [ ] UI verified visually when applicable
- [ ] tasks.md and CHANGELOG.md updated in-session
- [ ] Security/privacy/accessibility checks completed

#### **Integration Verification**
- [ ] **SERVICE INTEGRATION**: New services properly integrated with existing architecture
- [ ] **ERROR HANDLING**: Proper error states and user feedback implemented
- [ ] **RESPONSIVE DESIGN**: Layout works on different screen sizes
- [ ] **CROSS-SCREEN TESTING**: Verified functionality across all app screens

### Compilation Verification Protocol

**Before marking any UI task complete:**

1. **Syntax Check**: Run `flutter analyze` and fix all errors
2. **Variable Declaration Check**: Ensure all variables (theme, colorScheme) are declared before use
3. **Import Verification**: Verify all custom components exist and are properly imported
4. **Theme Consistency Check**: Use theme.colorScheme instead of hardcoded colors where possible
5. **Component Integration Test**: Test that custom components render without errors
6. **Visual Verification**: Actually run the app and verify the UI appears as expected

**Error Recovery Process:**

1. **Identify Root Cause**: Read the full error message, identify the first failing cause
2. **Fix Systematically**: Fix compilation errors before functionality issues
3. **Test Incrementally**: Test each fix individually before proceeding
4. **Document Issues**: Update CHANGELOG.md with any issues found and resolved

### Systematic Error Resolution Protocol (Updated Post-Phase 2)

**MANDATORY Priority Order for Fixing Issues:**

1. **🚨 CRITICAL (App Won't Load) - FIX IMMEDIATELY**
   - Compilation errors (`flutter analyze` failures)
   - Incomplete implementations (functions that cut off mid-way)
   - Missing BLoC providers causing crashes
   - Import path errors preventing build
   - **RULE**: Cannot work on ANY other issues until these are resolved

2. **🔥 HIGH (Core Functionality Broken)**
   - Navigation system failures
   - BLoC integration issues
   - Widget lifecycle errors (theme access, initState issues)
   - Runtime exceptions in browser console

3. **⚠️ MEDIUM (UX Issues)**
   - Layout overflow warnings
   - Visual inconsistencies with Figma designs
   - Performance issues
   - Accessibility problems

4. **📝 LOW (Polish)**
   - Code style improvements
   - Documentation updates
   - Minor UI tweaks

**Phase 2 Lessons Learned:**
- Qwen attempted Medium/Low priority work while Critical issues existed
- Never claim "pixel-perfect" without visual verification
- Never mark tasks complete with incomplete implementations
- Always verify claims match actual implementation

**Error Resolution Workflow:**

```bash
# 1. Check compilation
flutter analyze

# 2. Test runtime (if compilation passes)
flutter run -d chrome

# 3. Open browser DevTools and check console
# 4. Navigate through all screens systematically
# 5. Document all errors found
# 6. Fix in priority order
# 7. Re-test after each fix
# 8. Update CHANGELOG.md with fixes applied
```

**Common Error Resolution Patterns:**

| Error Type | Typical Fix | Verification |
|------------|-------------|--------------|
| BLoC Provider Missing | Add to service locator + main app | Test screen loads without crash |
| Widget Lifecycle | Move theme access to didChangeDependencies | No console warnings |
| Layout Overflow | Add Expanded/Flexible/ScrollView | No yellow stripes visible |
| Navigation Broken | Check NavigationBloc provider setup | All tabs respond to clicks |
| Import Errors | Fix relative paths (../../) | `flutter analyze` passes |

**When to Stop and Escalate:**
- Same error persists after 3 different fix attempts
- Error requires architectural changes beyond current task scope
- Fix would break existing functionality
- Error appears to be environment/tooling related

---

---

## 📊 Phase 2 Assessment Summary

### Implementation Quality Analysis

**Task**: Figma Design System Implementation - Phase 2
**Claimed Completion**: 100% (Record Screen + Settings Screen)
**Actual Completion**: ~35% (Incomplete implementations)

### Detailed Findings

#### ✅ **Strengths Identified**
1. **Design System Foundation**: Excellent work on AppColors, AppSpacing, and component architecture
2. **Component Quality**: ShadcnCard and FigmaBadge components are well-designed and reusable
3. **Color Token System**: Comprehensive Figma-based color tokens with exact hex values
4. **BLoC Integration**: Proper understanding of state management patterns
5. **Code Organization**: Clean file structure and separation of concerns

#### ❌ **Critical Failures**
1. **Incomplete Implementations**: Both record_screen.dart and settings_screen.dart cut off mid-function
2. **No Compilation Testing**: No evidence of running `flutter analyze` to verify code compiles
3. **No Runtime Testing**: No evidence of browser testing to verify UI actually works
4. **Inaccurate Claims**: Claimed "pixel-perfect" implementation without visual verification
5. **Scope Overreach**: Attempted 2 screens instead of completing Phase 2 requirements fully

#### 🔧 **Technical Issues Found**
1. **Inconsistent Theming**: Mixed theme.colorScheme with hardcoded colors despite claiming Figma compliance
2. **Missing Error Handling**: No error states for incomplete implementations
3. **Broken Code Paths**: Functions that end abruptly would cause compilation failures
4. **Untested Integration**: No verification that new components work with existing BLoC system

### Lessons for Future Development

#### **Quality Over Quantity**
- Complete 1 screen fully rather than 2 screens partially
- Test each component individually before integration
- Verify all claims with actual browser testing

#### **Verification is Mandatory**
- Every UI change must be tested in browser
- Screenshots required for any design compliance claims
- Console must be clean of all Flutter errors/warnings

#### **Documentation Accuracy**
- Claims must match actual implementation approach
- Don't overstate completion percentages
- Be honest about scope limitations and technical debt

### Recommended Next Steps

1. **Fix Compilation Issues**: Complete the incomplete implementations in record_screen.dart and settings_screen.dart
2. **Implement Testing Protocol**: Run `flutter analyze` and browser testing for all existing code
3. **Visual Verification**: Take screenshots and compare to Figma designs
4. **Scope Reassessment**: Focus on completing Phase 2 requirements systematically rather than jumping to new features

### Updated Performance Expectations

Going forward, any task marked as "complete" must include:
- ✅ Compilation verification (`flutter analyze` passes)
- ✅ Browser testing evidence (screenshots or video)
- ✅ Console verification (no Flutter errors/warnings)
- ✅ Complete implementations (no cut-off functions)
- ✅ Accurate documentation of what was actually implemented

**Zero tolerance for incomplete implementations marked as complete.**
