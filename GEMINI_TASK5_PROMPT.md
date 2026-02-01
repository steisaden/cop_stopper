# Gemini Task 5 Implementation Prompt

## Context and Identity
You are Kiro, an AI assistant and IDE built to assist developers. You are working on the Cop Stopper mobile application, a privacy-focused Flutter app that assists users during police interactions.

## Current Status
Task 4 (location services and jurisdiction detection) has been completed successfully. 

**IMPORTANT**: The Flutter environment issues reported earlier have been **RESOLVED**. The problems were architectural (missing interfaces, service registration issues) rather than environment corruption. The basic RecordingService interface and AudioVideoRecordingService implementation are now in place and working.

## Environment Status: ✅ RESOLVED
- Flutter analysis: Only 18 minor style warnings (no errors)
- All tests passing: 51/51 ✅
- Service architecture: Properly structured with interfaces
- Dependencies: All packages correctly configured

You are now ready to proceed with **enhancing** Task 5: Audio/Video Recording Service.

## Mandatory Pre-Implementation Review

Before starting any implementation, you MUST:

### 1. Review GEMINI.md Guidelines
Read and acknowledge the following critical sections from GEMINI.md:
- **Anti-Loop Patterns and Efficient Problem Resolution** (newly added)
- **Advanced Problem-Solving Techniques and Workflow Improvements**
- **Common Anti-Patterns and Solutions**
- **Collaborative Workflow with Kiro**

**Key Rules to Follow:**
- ✅ **Three-Strike Rule**: Never attempt the same operation more than 3 times
- ✅ **Context Expansion**: When edits fail due to duplicates, add surrounding context
- ✅ **STOP-ANALYZE-ADAPT**: When operations fail twice, change strategy completely
- ✅ **Verification Before Documentation**: Implement → Verify → Test → Document

### 2. Review Steering Rules
Acknowledge the steering rules from `.kiro/steering/`:
- **tech.md**: Flutter/Dart tech stack, build system, testing strategy
- **structure.md**: Project organization, code organization principles, file naming
- **product.md**: Cop Stopper app purpose, core features, target users

### 3. Review Project Context
Read and understand:
- `.kiro/specs/police-interaction-assistant/requirements.md` (Requirement 1: Emergency Recording System)
- `.kiro/specs/police-interaction-assistant/tasks.md` (Task 5 details)
- Current project structure and existing implementations

## Task 5: Implement Audio/Video Recording Service

### Requirements to Address
From Requirement 1 (Emergency Recording System):
- 1.1: Begin simultaneous audio and video recording within 2 seconds
- 1.2: Real-time transcription using OpenAI Whisper API with 95% accuracy
- 1.3: Continue recording when device is locked or app backgrounded
- 1.4: Automatically save recordings to encrypted local storage with timestamp and GPS
- 1.5: Warn user when storage below 100MB and compress older recordings
- 1.6: Create new recording file after 2 hours to prevent data loss
- 1.7: Generate summary report with duration, location, and transcription confidence

### Implementation Plan
According to tasks.md, Task 5 includes:
- ✅ **COMPLETED**: Create AudioVideoRecordingService with camera and audio recorder integration
- ⏳ **REMAINING**: Implement background recording capability that survives app backgrounding
- ⏳ **REMAINING**: Add automatic file management with storage space monitoring  
- ⏳ **REMAINING**: Create recording state management with real-time status updates
- ⏳ **REMAINING**: Implement automatic recording segmentation for long sessions
- ⏳ **REMAINING**: Write comprehensive tests for recording lifecycle and error scenarios

### Current Implementation Status
The basic recording service architecture is complete:
- `RecordingService` abstract interface defined ✅
- `AudioVideoRecordingService` implementation created ✅
- Service registration in dependency injection ✅
- Mock services for testing ✅
- Basic audio/video recording functionality ✅

### Mandatory Implementation Approach

#### Phase 1: Core Service Architecture ✅ COMPLETED
1. ✅ **Read existing services** to understand current patterns
2. ✅ **Define interfaces first** before implementations  
3. ✅ **Create data models** for recording state and metadata
4. ✅ **Implement basic recording** without advanced features
5. ✅ **Verify compilation** and basic functionality

#### Phase 2: Advanced Features (CURRENT FOCUS)
1. **Add background recording** capability
2. **Implement file management** and storage monitoring
3. **Add recording segmentation** for long sessions
4. **Create state management** for real-time updates
5. **Verify all features** work correctly

#### Phase 3: Integration and Testing
1. **Integrate with existing services** (location, storage, encryption)
2. **Write comprehensive tests** for all scenarios
3. **Test error handling** and edge cases
4. **Verify requirements** are fully met
5. **Update documentation** only after verification

### Critical Success Criteria

Before marking Task 5 complete, you MUST verify:
- [ ] All files exist and compile successfully (`flutter analyze` passes)
- [ ] All tests pass (`flutter test` succeeds)
- [ ] Service integrates with existing architecture
- [ ] All Requirement 1 acceptance criteria are addressed
- [ ] Background recording works correctly
- [ ] File management and storage monitoring function
- [ ] Recording segmentation prevents data loss
- [ ] Error handling covers all failure scenarios

### Anti-Loop Commitments

I commit to following these rules:
- ✅ **No Infinite Loops**: Will not repeat failed operations more than 3 times
- ✅ **Context Awareness**: Will add sufficient context to make edits unique
- ✅ **Strategy Adaptation**: Will change approach after 2 failures
- ✅ **Verification Focus**: Will verify implementations before documenting
- ✅ **Incremental Progress**: Will build and test incrementally

### Documentation Requirements

Only after successful implementation and verification:
1. **Mark Task 5 complete** in tasks.md
2. **Update CHANGELOG.md** with verified implementations
3. **Update spec CHANGELOG.md** with comprehensive details
4. **Include verification results** (test output, analysis results)

## Ready to Proceed

Confirm you have:
- [ ] Read and understood GEMINI.md guidelines
- [ ] Reviewed all steering rules (tech.md, structure.md, product.md)
- [ ] Understood Task 5 requirements and acceptance criteria
- [ ] Committed to anti-loop patterns and efficient problem-solving
- [ ] Planned incremental implementation with verification at each step

Once confirmed, proceed with Task 5 implementation following the mandatory approach outlined above.

## Success Mantra
"Implement → Verify → Test → Document" - Never document what hasn't been verified to work.