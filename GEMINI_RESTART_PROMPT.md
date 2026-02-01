# Gemini Restart Prompt - Cop Stopper Project

## Project Context

You are working on the **Cop Stopper Mobile Application** - a privacy-focused mobile app that assists users during police interactions. The project uses Flutter/Dart for cross-platform mobile development with a Node.js backend.

## Current Project Status

### ✅ **Completed Work**
- **Spec Creation**: Complete requirements, design, and implementation plan created
- **Project Structure**: Flutter project set up in `mobile/` directory with Docker support
- **Dependencies**: Package compatibility issues resolved for Dart SDK 2.18.6
- **Documentation**: Comprehensive development guide in GEMINI.md

### 📁 **Key Files to Review**
1. **`.kiro/specs/police-interaction-assistant/requirements.md`** - 7 detailed requirements with EARS format acceptance criteria
2. **`.kiro/specs/police-interaction-assistant/design.md`** - Complete system architecture and technical design
3. **`.kiro/specs/police-interaction-assistant/tasks.md`** - 20 sequential implementation tasks
4. **`GEMINI.md`** - Comprehensive development guide with troubleshooting
5. **`mobile/pubspec.yaml`** - Flutter project with compatible dependencies

### 🎯 **Current Task Focus**
You should be working on **Task 1** from the implementation plan: "Set up project structure and core dependencies"

However, there are **Docker Flutter environment issues** that need to be resolved first.

## Critical Issue to Address

### 🚨 **Docker Flutter Environment Problem**
- **Issue**: Flutter tests fail with missing core dependencies (`vector_math`, `characters`) and undefined types (`Matrix4`)
- **Impact**: Blocking all Flutter development tasks
- **Status**: Environment appears corrupted despite `flutter pub get` and `flutter clean`

### 🔧 **Solution Required**
Follow the troubleshooting steps in GEMINI.md under "Docker Flutter Environment Corruption Issues":

1. **Nuclear Reset**: Complete Docker environment reset
2. **Container Rebuild**: Fresh Flutter container from scratch  
3. **Verification**: Check Flutter SDK integrity
4. **Alternative**: Update to newer Flutter Docker image if needed

## Your Next Actions

### 1. **First Priority: Fix Docker Environment**
```bash
# Complete reset (recommended)
docker-compose down --volumes --remove-orphans
docker-compose build --no-cache app
docker-compose run --rm app flutter doctor -v
docker-compose run --rm app flutter pub get
docker-compose run --rm app flutter test
```

### 2. **Once Environment is Fixed: Start Task 1**
From `.kiro/specs/police-interaction-assistant/tasks.md`:

**Task 1**: Set up project structure and core dependencies
- Create Flutter project with proper directory structure for services, models, and UI
- Configure pubspec.yaml with required dependencies
- Set up platform-specific permissions in AndroidManifest.xml and Info.plist
- Create base service interfaces and dependency injection setup

### 3. **Development Approach**
- **Read the spec files first** to understand requirements and design
- **Follow the task list sequentially** - each task builds on the previous
- **Use Docker commands** as documented in GEMINI.md
- **Test frequently** to catch issues early

## Key Project Details

### **Core Features to Implement**
1. **Emergency Recording System**: Audio/video recording with transcription
2. **AI Legal Guidance**: Context-aware legal advice based on location
3. **Secure Document Storage**: Encrypted storage with biometric access
4. **Officer Records Lookup**: Public records search functionality
5. **Location Services**: GPS-based jurisdiction detection
6. **Privacy Framework**: End-to-end encryption and GDPR compliance

### **Technical Stack**
- **Frontend**: Flutter/Dart (cross-platform mobile)
- **Backend**: Node.js with Express, PostgreSQL database
- **Security**: AES-256 encryption, OAuth 2.0 authentication
- **APIs**: OpenAI Whisper, location services, public records APIs

### **Development Environment**
- **Docker-based**: All Flutter commands via `docker-compose run --rm app`
- **Package versions**: Specifically chosen for Dart SDK 2.18.6 compatibility
- **Testing**: Dart test framework with widget and integration tests

## Success Criteria

### **Environment Fixed When**:
- ✅ `docker-compose run --rm app flutter test` runs without compilation errors
- ✅ No "undefined name 'Matrix4'" or missing package errors
- ✅ `flutter doctor` shows healthy Flutter installation
- ✅ Core Flutter dependencies (`vector_math`, `characters`) are available

### **Ready to Proceed When**:
- ✅ Docker Flutter environment is stable
- ✅ All spec documents reviewed and understood
- ✅ Task 1 requirements are clear
- ✅ Development workflow is established

## Important Notes

- **Don't skip the environment fix** - it will block all subsequent work
- **Follow the task sequence** - each task builds on the previous ones
- **Use the spec documents** as your source of truth for requirements
- **Test frequently** using the Docker commands provided
- **Document any issues** you encounter for future reference

## Getting Started Command

```bash
# Start here - this should be your first command:
docker-compose run --rm app flutter doctor -v

# If that shows issues, follow the complete reset procedure in GEMINI.md
```

---

**Remember**: You're building a critical privacy and safety application. Quality, security, and reliability are paramount. Take time to understand the requirements and design before implementing.