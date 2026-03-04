# IDEATION REPORT: VoiceInk (All Categories)
# Date: 2026-03-02

## Overall Summary

| Category | Critical | High | Medium | Low | Total |
|----------|----------|------|--------|-----|-------|
| Performance | 2 | 5 | 8 | 4 | 19 |
| Security | 0 | 4 | 6 | 5 | 15 |
| Code Quality | 4 | 10 | 9 | 5 | 28 |
| Architecture | 2 | 4 | 5 | 5 | 16 |
| Opportunities | 0 | 3 | 6 | 5 | 14 |
| UX | 2 | 12 | 10 | 6 | 30 |
| **Total** | **10** | **38** | **44** | **30** | **122** |

---

## Critical Findings (10) -- Fix Immediately

### Code Quality

**CQ-C1: Force-unwrapped `enhancementService!` at 3 window creation sites**
- Files: `HistoryWindowController.swift:36`, `MiniWindowManager.swift:56`, `NotchWindowManager.swift:55`
- `whisperState.enhancementService` is declared as `AIEnhancementService?` (optional). All three window-creation sites force-unwrap it with `!`. Crashes if enhancement service is nil.
- Fix: Use `guard let` before window creation, fail gracefully.

**CQ-C2: Force-unwrapped `AVAudioFormat`/`AVAudioPCMBuffer` in audio callback**
- File: `ParakeetStreamingProvider.swift:79-85`
- Three chained `!` on every audio chunk: `AVAudioFormat(...)!`, `AVAudioPCMBuffer(...)!`, `buffer.floatChannelData![0]`. Crashes on zero-byte data or invalid format.
- Fix: Add `guard let` for each, throw or return early.

**CQ-C3: Force-unwrapped `allPrompts.first!` on AI enhancement hot path**
- File: `AIEnhancementService.swift:256`
- Called every time an enhancement is performed. If `allPrompts` is empty (first launch, failed decode), crashes.
- Fix: Use `guard let ... else { throw EnhancementError.notConfigured }`.

**CQ-C4: Implicitly-unwrapped `serviceRegistry!`**
- File: `WhisperState.swift:102`
- `internal var serviceRegistry: TranscriptionServiceRegistry!` -- any access before assignment crashes with no useful stack info.
- Fix: Make non-optional and initialize inline, or use `lazy var`.

### Performance

**PERF-C1: Unbounded SwiftData fetches loading entire history**
- `TranscriptionHistoryView` fetches all records with no pagination limit on initial load.
- Fix: Add `fetchLimit` and implement incremental loading.

**PERF-C2: Synchronous I/O on MainActor during import/export**
- `ImportExportService` performs file reads/writes blocking the main thread.
- Fix: Move file I/O to background queue, update UI on main thread.

### Architecture

**ARCH-C1: WhisperState is a 1,480+ line god object**
- 7 extension files, 10+ responsibilities: recording state machine, model lifecycle, model download, UI window management, transcription orchestration, AI enhancement invocation, audio file management, session management, pasting.
- Fix (incremental): Extract `TranscriptionOrchestrator`, `RecorderWindowCoordinator`, `ModelDownloadManager`.

**ARCH-C2: Massive App struct init**
- `VoiceInk.swift` creates all core services synchronously in `init()`, blocking app launch.
- Fix: Use lazy initialization or move non-essential service creation to `onAppear`.

### UX

**UX-C1: Alert binding with `.constant()` prevents dismissal**
- File: `AudioTranscribeView.swift:44`
- The error alert is bound with `.constant(transcriptionManager.errorMessage != nil)`. SwiftUI cannot set the binding back to `false` to dismiss. Escape key dismiss is broken.
- Fix: Use a proper `Binding(get:set:)` or `@State var showError`.

**UX-C2: Record button and checkbox toggle have no VoiceOver labels**
- Files: `RecorderComponents.swift:70`, `TranscriptionListItem.swift:12`
- The primary record button has `accessibilityIdentifier` but no `.accessibilityLabel`. VoiceOver announces "button" with no context. Checkbox toggle says "switch, off" with no transcription identification.
- Fix: Add `.accessibilityLabel()` with dynamic state descriptions.

---

## High Findings (38)

### Security (4 High)

**SEC-H1: No App Sandbox**
- File: `VoiceInk.entitlements:16`
- `com.apple.security.app-sandbox` is `false`. Combined with screen capture, Apple Events, network server, and audio input entitlements. A compromised process has full user-level access.
- Fix: Document decision explicitly. Consider enabling sandbox with temporary exceptions.

**SEC-H2: Transcription text logged as `privacy: .public`**
- File: `WhisperState.swift:399-463`
- Five `.notice` log lines output verbatim transcription text (which may contain passwords, medical info) as `.public`. Readable in Console.app by any local process.
- Fix: Change to `privacy: .private` or `privacy: .sensitive`.

**SEC-H3: License API responses logged as `.public`**
- File: `PolarService.swift:76-78, 124-126, 156-158`
- Full JSON response body from Polar license API logged with `privacy: .public`. Contains activation IDs.
- Fix: Log only status code as `.public`, mark response body `.private`.

**SEC-H4: Custom provider URLs accept HTTP**
- Files: `CustomModelManager.swift:129-134`, `AIService.swift:43-46`
- `isValidURL` accepts any scheme including `http://`. API keys sent in plaintext if user configures HTTP endpoint. Ollama base URL also configurable to remote HTTP.
- Fix: Enforce `https://` except for localhost addresses.

### Code Quality (10 High)

**CQ-H1: Dead notification observers never posted**
- Files: `NotchWindowManager.swift:19`, `MiniWindowManager.swift:25`
- Subscribe to `"HideNotchRecorder"` and `"HideMiniRecorder"` but zero `.post()` calls exist. Dead code.
- Fix: Remove observers and handlers, or add posting sites if intended.

**CQ-H2: Duplicated vocabulary-fetching logic across 3 services**
- Files: `CloudTranscriptionService.swift:157-174`, `DeepgramStreamingProvider.swift:91-108`, `SonioxStreamingProvider.swift:91-108`
- Identical `getCustomDictionaryTerms()` / `getCustomVocabularyTerms()` functions. `CustomVocabularyService` exists but is not used.
- Fix: Add method to `CustomVocabularyService`, call from all three services.

**CQ-H3: Regex recompiled on every transcription (hot path)**
- Files: `TranscriptionOutputFilter.swift:18,22,35`, `AIEnhancementOutputFilter.swift:11`
- `NSRegularExpression` objects compiled from scratch on every invocation. `WordReplacementService` already demonstrates the correct caching pattern.
- Fix: Use static cached regexes.

**CQ-H4: Missing `@MainActor` on `MiniWindowManager`**
- File: `MiniWindowManager.swift:4`
- Manages `NSWindowController`, `NSPanel`, and `@Published` properties (all require main thread). `NotchWindowManager` is correctly annotated; this one is not.
- Fix: Add `@MainActor` annotation.

**CQ-H5: Raw notification name strings bypass `AppNotifications.swift` (8 sites)**
- Files: `AudioDeviceManager.swift:524`, `PowerModeConfig.swift:163`, `CustomSoundManager.swift:120`, `PowerModeShortcutManager.swift:17`, `MiniWindowManager.swift:25`, `NotchWindowManager.swift:19`, `SoundManager.swift:25`, `AudioDeviceConfiguration.swift:40`
- Typo in any raw string silently breaks the feature.
- Fix: Add all names to `AppNotifications.swift`, replace raw strings.

**CQ-H6: `NSScreen.screens.first!` crashes in headless environments**
- File: `WhisperState.swift:68, 72, 75`
- `NSScreen.screens` is empty when app runs headless. The fallback chain ends with `!`.
- Fix: Return optional or provide safe default.

**CQ-H7: Silent `try? modelContext.save()` on 9+ critical paths**
- Files: `WhisperState.swift:200,346,506,520`, `TranscriptionHistoryView.swift:657`, `TranscriptionMetadataView.swift:30`, `AudioCleanupManager.swift:171`, `ImportExportService.swift:296,333,367`
- Save failures silently swallowed. Transcription records inserted in-memory but never persisted = data loss.
- Fix: Use `do { try } catch { logger.error(...) }`. Surface critical save failures to user.

**CQ-H8: Silent model load failures on startup**
- File: `WhisperState+ModelManagement.swift:48-52`
- `try? await self.loadModel(localModel)` and `try? await ... loadModel(for: parakeetModel)` -- failures disappear silently, recording fails or falls through.
- Fix: Catch and log, notify user.

**CQ-H9: Force-unwrap in `AudioFileProcessor` buffer construction**
- File: `AudioFileProcessor.swift:170-171`
- `int16Buffer.baseAddress!` is nil when samples array is empty. `buffer.int16ChannelData![0]` is nil for format mismatch.
- Fix: Guard both values, throw typed error.

**CQ-H10: 30+ `print()` calls for error paths invisible in production**
- Files: `TranscriptionHistoryView.swift` (7), `ImportExportService.swift` (6), `PowerModeSessionManager.swift` (5), `OllamaService.swift`, `MenuBarManager.swift`, others
- `print()` bypasses `os.Logger` subsystem (no filtering, no privacy). `os.Logger` is already used correctly elsewhere.
- Fix: Replace with `Logger(subsystem:category:).error(...)`.

### UX (12 High)

**UX-H1: RecorderToggleButton has no accessible label**
- File: `RecorderComponents.swift:46-59`
- VoiceOver reads raw SF Symbol identifier or nothing for emoji buttons.
- Fix: Add `.accessibilityLabel()` describing the action.

**UX-H2: CircularCheckboxStyle toggle has no accessibility label**
- File: `TranscriptionListItem.swift:64-76`
- Custom button inside toggle has only an image. VoiceOver cannot describe what selecting does.
- Fix: Add `.accessibilityLabel("Select/Deselect transcription")`.

**UX-H3: Hard-coded `Color.white` in 23 files**
- Key offenders outside intentionally dark recorder: `PermissionsView.swift:175`, `AudioPlayerView.swift:182`, `OnboardingModelDownloadView.swift:52,57`
- Fragile if background changes.
- Fix: Audit each site. Use `.primary`/`.secondary` where background is not explicitly dark.

**UX-H4: No delete confirmation in WordReplacementView**
- File: `WordReplacementView.swift:242-253`
- `xmark.circle.fill` button immediately deletes with no confirmation or undo. History multi-delete correctly shows confirmation.
- Fix: Add `.alert` or `.confirmationDialog` before deleting.

**UX-H5: No delete confirmation in VocabularyView**
- File: `VocabularyView.swift:297`
- Same pattern as UX-H4. Immediate deletion, no confirmation.
- Fix: Add confirmation dialog.

**UX-H6: "Dismiss All" in VocabularySuggestionsView has no confirmation**
- File: `VocabularySuggestionsView.swift:161-170`
- Bulk destructive action with no confirmation, no undo, no visual feedback.
- Fix: Add `.confirmationDialog` with destructive-role button.

**UX-H7: InfoTip uses `onTapGesture` instead of `Button`**
- File: `InfoTip.swift:50`
- Not keyboard-focusable, invisible to VoiceOver as interactive element. Used across dozens of views.
- Fix: Wrap in `Button` with `.buttonStyle(.plain)` and add `.accessibilityLabel`.

**UX-H8: Audio input move-up/down buttons missing `.help()` and labels**
- File: `AudioInputSettingsView.swift:410-420`
- Chevron buttons for reordering audio devices have no tooltip or accessibility label.
- Fix: Add `.help("Move up")` and `.accessibilityLabel("Move device up")`.

**UX-H9: Audio input priority toggle button missing `.help()` and label**
- File: `AudioInputSettingsView.swift:425`
- `plus.circle.fill` / `minus.circle.fill` button with no tooltip or accessibility label.
- Fix: Add `.help()` and `.accessibilityLabel()`.

**UX-H10: History sidebar row uses plain `Button`, breaks keyboard navigation**
- File: `ContentView.swift:111-122`
- All other sidebar items use `NavigationLink`. History is a plain `Button` that opens NSWindow. Cannot be selected with keyboard.
- Fix: Architectural -- History lives in its own window deliberately. At minimum match visual style.

**UX-H11: Play/pause and settings gear buttons missing `.help()` tooltips**
- Files: `AudioPlayerView.swift:317`, `ModelManagementView.swift:106`, `LocalModelCardRowView.swift:186`
- Icon-only buttons with no tooltips. Inconsistent with other buttons that do have `.help()`.
- Fix: Add `.help()` to all icon-only buttons.

**UX-H12: Enhancement settings disabled state misleading**
- File: `EnhancementSettingsView.swift:56,62,99,121`
- Controls at `opacity(0.8)` look inactive but are still interactive. Not `.disabled()` when enhancement is off.
- Fix: Apply `.disabled(!enhancementService.isEnhancementEnabled)`, remove manual opacity.

### Performance (5 High)

**PERF-H1: Repeated per-transcription DB fetches in cleanup service**
- Cleanup service fetches transcription data individually for each record during batch operations.
- Fix: Use batch fetch with predicate.

**PERF-H2: Missing caches for vocabulary lookups**
- Vocabulary terms re-fetched from SwiftData on every transcription.
- Fix: Cache vocabulary list, invalidate on changes.

**PERF-H3: O(n*m) hot-path loops in word replacement**
- `WordReplacementService` iterates all replacements against each transcription segment.
- Fix: Pre-compile lookup dictionary.

**PERF-H4: Full model list re-sorted on every view update**
- Model management view re-sorts the complete model array on each SwiftUI body evaluation.
- Fix: Cache sorted list, update on model changes only.

**PERF-H5: Redundant vocabulary fetches across transcription services**
- Three services independently fetch the same vocabulary data (overlaps with CQ-H2).
- Fix: Share via `CustomVocabularyService`.

### Architecture (4 High)

**ARCH-H1: 38 singletons across the codebase**
- Extensive use of `.shared` singletons makes testing impossible and creates hidden dependencies.
- Fix: Gradually migrate to dependency injection, starting with most-used services.

**ARCH-H2: 250-line `transcribeAudio` method with 8+ responsibilities**
- File: `WhisperState.swift`
- Handles recording stop, file management, service selection, transcription, text filtering, word replacement, enhancement, and pasting.
- Fix: Extract into `TranscriptionOrchestrator` with single-responsibility methods.

**ARCH-H3: Duplicated LLM request construction code**
- LLM request building logic repeated across enhancement service and individual provider clients.
- Fix: Centralize in a shared request builder.

**ARCH-H4: Circular dependency LocalTranscriptionService <-> WhisperState**
- `LocalTranscriptionService` references `WhisperState` which references it back through `serviceRegistry`.
- Fix: Use a protocol abstraction to break the cycle.

### Opportunities (3 High)

**OPP-H1: Duplicated LLM request logic across enhancement services**
- Same as ARCH-H3. Consolidation opportunity.

**OPP-H2: Unguarded `try?` on save throughout codebase**
- 20+ `try? modelContext.save()` with zero error visibility. Same as CQ-H7.
- Fix: Systematic replacement with logged error handling.

**OPP-H3: Zero unit tests for any business logic**
- VoiceInkTests has signing/deployment-target issues. No working test suite exists.
- Fix: Set up test target, start with critical business logic (word replacement, output filtering, vocabulary service).

---

## Medium Findings (44)

### Security Medium (6)
- **SEC-M1:** URL substring matching in PowerMode bypassable via path traversal (`PowerModeConfig.swift:196-209`)
- **SEC-M2:** Path traversal in `TranscribeAudioFileIntent` via user-supplied filename (`TranscribeAudioFileIntent.swift:27-30`)
- **SEC-M3:** `Obfuscator` uses Base64 not encryption -- should be removed (`Obfuscator.swift`)
- **SEC-M4:** Unsigned remote content fetched for announcements (`AnnouncementsService.swift:44-63`)
- **SEC-M5:** Audio files written without explicit file protection (`WhisperState.swift:137-141`)
- **SEC-M6:** `com.apple.security.network.server` entitlement may be unnecessary (`VoiceInk.entitlements:25`)

### Code Quality Medium (9)
- **CQ-M1:** Massive `var body` implementations (343-408 lines) in SettingsView, PowerModeConfigView, TranscriptionMetadataView
- **CQ-M2:** `try? modelContext.save()` without logging in 6 additional locations
- **CQ-M3:** Duplicated filter menu UI (50 lines repeated) in TranscriptionHistoryView
- **CQ-M4:** WhisperState god object (overlaps with ARCH-C1)
- **CQ-M5:** `print()` for errors instead of Logger in 6 files (overlaps with CQ-H10)
- **CQ-M6:** 55 raw UserDefaults key strings, no centralization across 20+ files
- **CQ-M7:** Force unwrap inside nil-guard in LibWhisper (`if prompt != nil { ... prompt!.utf8CString }`)
- **CQ-M8:** Silent catch blocks without debug logging in AudioCleanupManager
- **CQ-M9:** Duplicate `filteredTranscriptions` logic in TranscriptionHistoryView

### UX Medium (10)
- **UX-M1:** TranscriptionListItem uses `onTapGesture` instead of `Button` (not keyboard-navigable)
- **UX-M2:** Model download progress indeterminate in button during download
- **UX-M3:** Audio player has no keyboard-accessible seek control
- **UX-M4:** API key status dots have no accessibility label
- **UX-M5:** ModelSettingsView "Edit" has no "Cancel" button
- **UX-M6:** ContentView fixed 950px width prevents window resizing
- **UX-M7:** PhoneticHintReviewSheet has fixed frame width
- **UX-M8:** "Clear Filters" button in history has no accessibility label
- **UX-M9:** Audio file validation provides no feedback for rejected files
- **UX-M10:** Metrics load error shows empty state instead of error message

### Performance Medium (8)
- Sync file operations on main thread in multiple services
- No caching of screen capture OCR results
- Repeated `DateFormatter` creation
- Full re-render of list on single item change
- Model download progress polling interval too aggressive
- Vocabulary suggestion generation blocks main thread
- No debouncing on search text filtering
- Audio level meter updates at excessive frame rate

### Architecture Medium (5)
- No protocol abstractions for transcription services (concrete types everywhere)
- Settings scattered across UserDefaults, SwiftData, and Keychain with no unified access
- View models and views tightly coupled (26 @State properties in TranscriptionHistoryView)
- PowerMode configuration stored as JSON string in UserDefaults
- Import/export service mixes model manipulation, UI coordination, and file I/O (496 lines)

### Opportunities Medium (6)
- No `@Observable` adoption despite targeting macOS 14.4+
- Completion-handler APIs in otherwise async codebase (`AIService.swift:301,323,374`)
- Scattered UserDefaults keys (same as CQ-M6)
- Redundant vocabulary fetches (same as CQ-H2)
- Regex recompilation on hot path (same as CQ-H3)
- WhisperState god object (same as ARCH-C1)

---

## Low Findings (30)

### Security Low (5)
- Screen capture and clipboard data held indefinitely in memory
- No audio file size limit before permanent copy in re-transcribe
- Diagnostics log export writes to ~/Downloads without save panel
- `SetLanguageCommand` (AppleScript) accepts arbitrary language codes
- `com.apple.security.network.server` entitlement may be unnecessary (overlap with SEC-M6)

### Code Quality Low (5)
- `ConfigurationType` enum defined but never used
- 13 `Task.sleep(nanoseconds:)` calls using deprecated API
- Completion handlers in async-first codebase
- `VocabularySuggestionsView` catch blocks missing error logging
- `DispatchQueue.main` inside `@MainActor` class (4 sites in WhisperState)

### UX Low (6)
- Timer in `ProgressAnimation` may fire off main thread
- Model filter tabs lack keyboard shortcut / segmented control
- Sort button tooltip doesn't indicate current direction
- Redundant `Task { await MainActor.run }` in CloudModelCardView
- Enhancement panel Escape key does not close it
- Inconsistent icon button sizing across the app

### Performance Low (4)
- Minor memory allocations in tight audio loops
- Unnecessary object creation in notification handlers
- View hierarchy too deep in some settings sections
- String interpolation in disabled log statements

### Architecture Low (5)
- No formal error types (strings used for error messages)
- NotificationCenter used where Combine publishers would be more appropriate
- App delegate and App struct both handle initialization
- No dependency injection container
- Mixed concurrency models (GCD + async/await + Combine)

### Opportunities Low (5)
- Stale TODO comments referencing completed work
- Unused imports in several files
- Magic numbers for animation durations
- Inconsistent naming conventions for notification handlers
- Custom URL scheme handling could use modern SwiftUI `.onOpenURL`
