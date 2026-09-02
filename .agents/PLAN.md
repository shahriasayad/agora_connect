# PLAN.md — AgoraConnect

## Objective

Build a production-ready Flutter application called **AgoraConnect** with:

- 1-to-1 audio calling
- 1-to-1 video calling
- Incoming calls
- Outgoing calls
- Secure Agora token authentication
- Clean, scalable architecture
- Android and iOS support

Do not implement unnecessary features outside the scope of audio/video calling.

---

# Phase 1 — Project Initialization

### Tasks

- Verify the existing Flutter project.
- Add `agora_rtc_engine`.
- Configure Android permissions.
- Configure iOS permissions.
- Create a clean feature-based architecture.
- Create environment/configuration handling.
- Keep Agora configuration isolated from UI code.

### Verify

- Project builds successfully.
- Agora package resolves correctly.
- Android and iOS permissions are configured.

---

# Phase 2 — Agora RTC Core

### Tasks

- Create a dedicated `AgoraService`.
- Initialize the Agora RTC engine.
- Configure RTC settings.
- Register all required Agora event handlers.
- Implement channel joining.
- Implement channel leaving.
- Implement engine disposal.
- Implement local user state.
- Implement remote user state.

### Verify

- Agora initializes without errors.
- User can join a channel.
- User can leave a channel.
- Engine is properly disposed.

---

# Phase 3 — Video Calling

### Tasks

Create the complete 1-to-1 video calling flow.

Implement:

- Local video preview
- Remote video rendering
- Microphone mute/unmute
- Camera enable/disable
- Front/rear camera switch
- Speaker control
- End call
- Connection status
- Remote user joined
- Remote user left

### Verify

Test with two separate devices.

Expected:

```text
Device A → joins channel
Device B → joins same channel
Device A → sees Device B
Device B → sees Device A
Audio → works
Video → works
Controls → work
End call → works


Production Hardening

Before release:

Remove mock data.
Remove debug-only logic.
Remove hardcoded production secrets.
Verify backend security.
Verify token expiration.
Verify resource cleanup.
Verify Agora event handling.
Verify crash/error handling.
Verify Android configuration.
Verify iOS configuration.
Verify release builds.


### Development Rules

Implement one phase at a time.
Do not move to the next phase until the current phase builds and works.
Keep Agora logic inside dedicated services/classes.
Do not place business logic directly inside widgets.
Do not expose the Agora App Certificate in Flutter.
Prefer simple, maintainable implementations over unnecessary abstractions.
Do not add features outside this plan unless explicitly requested.
After each phase, run/build/test the project and fix errors before continuing.
Keep the application usable after every major phase.
Document important configuration and setup requirements.



Final Architecture
Flutter App
│
├── Authentication
├── Users
├── Calling
│   ├── Audio
│   ├── Video
│   ├── Incoming Calls
│   └── Outgoing Calls
│
├── Agora Service
├── API Layer
└── Call State Management
        │
        ▼
     Backend
        │
        ├── Authentication
        ├── Call Session
        └── Agora Token Generation
                │
                ▼
             Agora RTC