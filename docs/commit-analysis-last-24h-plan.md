# Last 24 Hours Commit Analysis and Remediation Plan

## Scope reviewed
I reviewed all 17 commits from **March 1–2, 2026** (last 24 hours), including feature, fix, revert, merge, and docs commits. I focused on net `HEAD` behavior plus risky churn inside reverted/reworked areas.

## Findings (ordered by severity)
1. **Mode semantics are internally inconsistent (`off` can still run background enhancement).**
   Files:
   - [SetEnhancementModeIntent.swift](/Users/jeff/Developer/GitHub/VoiceInk/VoiceInk/AppIntents/SetEnhancementModeIntent.swift#L33)
   - [ScriptCommands.swift](/Users/jeff/Developer/GitHub/VoiceInk/VoiceInk/Scripting/ScriptCommands.swift#L40)
   - [ScriptableProperties.swift](/Users/jeff/Developer/GitHub/VoiceInk/VoiceInk/Scripting/ScriptableProperties.swift#L35)
   - [AIEnhancementService.swift](/Users/jeff/Developer/GitHub/VoiceInk/VoiceInk/Services/AIEnhancement/AIEnhancementService.swift#L60)

   Problem:
   `off` only sets `enhancementMode = .off`; it does not clear `backgroundEnhancementEnabled`. Also script property reports `enhancementMode.rawValue`, not `effectiveEnhancementMode`. This can report `"off"` while background enhancement is actually active.

2. **AppleScript threading approach is brittle (`MainActor.assumeIsolated` in ObjC entrypoints).**
   Files:
   - [ScriptCommands.swift](/Users/jeff/Developer/GitHub/VoiceInk/VoiceInk/Scripting/ScriptCommands.swift#L20)
   - [ScriptableProperties.swift](/Users/jeff/Developer/GitHub/VoiceInk/VoiceInk/Scripting/ScriptableProperties.swift#L6)

   Problem:
   `assumeIsolated` is only safe when already on main actor. In script command/property entrypoints, this assumption can be violated and can crash or trigger undefined behavior.

3. **Potential PII leakage / oversized responses in AppIntents dialogs.**
   Files:
   - [GetLastTranscriptionIntent.swift](/Users/jeff/Developer/GitHub/VoiceInk/VoiceInk/AppIntents/GetLastTranscriptionIntent.swift#L23)
   - [TranscribeAudioFileIntent.swift](/Users/jeff/Developer/GitHub/VoiceInk/VoiceInk/AppIntents/TranscribeAudioFileIntent.swift#L38)
   - [SearchTranscriptionsIntent.swift](/Users/jeff/Developer/GitHub/VoiceInk/VoiceInk/AppIntents/SearchTranscriptionsIntent.swift#L48)

   Problem:
   Full transcript text is echoed in dialog strings. Dialog channels are less appropriate for large/sensitive text than return values.

4. **Search intent misses older matches by design.**
   File:
   - [SearchTranscriptionsIntent.swift](/Users/jeff/Developer/GitHub/VoiceInk/VoiceInk/AppIntents/SearchTranscriptionsIntent.swift#L25)

   Problem:
   Fetch is capped at 100 newest transcriptions before filtering, so valid older matches are silently excluded.

5. **Audio-file intent uses full in-memory write and non-unique temp filename.**
   File:
   - [TranscribeAudioFileIntent.swift](/Users/jeff/Developer/GitHub/VoiceInk/VoiceInk/AppIntents/TranscribeAudioFileIntent.swift#L27)

   Problem:
   `file.data.write` loads all data and writes to potentially colliding filename from input metadata. Risk: memory pressure for large files and temp-path collisions.

6. **Suggestion approval path can insert duplicate vocabulary entries.**
   File:
   - [VocabularySuggestionsView.swift](/Users/jeff/Developer/GitHub/VoiceInk/VoiceInk/Views/Dictionary/VocabularySuggestionsView.swift#L115)

   Problem:
   `approve`/`approveAll` inserts without re-checking current dictionary contents. If state changed after suggestion generation, duplicates are possible.

7. **Docs are stale relative to same-day MLX removal.**
   Files:
   - [local-model-experiments.md](/Users/jeff/Developer/GitHub/VoiceInk/docs/local-model-experiments.md#L1)
   - [pr-description.md](/Users/jeff/Developer/GitHub/VoiceInk/docs/pr-description.md#L67)

   Problem:
   Docs still describe MLX provider and workflows that were removed in commit `a62e928...`, which creates operator confusion.

8. **Coverage gap: new automation surface has almost no automated tests.**
   Files:
   - [VoiceInkUITests.swift](/Users/jeff/Developer/GitHub/VoiceInk/VoiceInkUITests/VoiceInkUITests.swift#L17)
   - New AppIntents/AppleScript files under `/VoiceInk/AppIntents` and `/VoiceInk/Scripting`

   Problem:
   Current UI tests only cover sidebar presence/navigation smoke checks. No tests for new intent behavior, mode semantics, or AppleScript command/property correctness.

## Plan (do not execute)
1. **Normalize enhancement mode model.**
   Define one canonical setter API (e.g., `setEnhancementMode(_:)`) that atomically updates both `enhancementMode` and `backgroundEnhancementEnabled`; update AppIntents and AppleScript commands to use it; have script/intents report `effectiveEnhancementMode`.

2. **Replace `assumeIsolated` usage in scripting layer.**
   Use safe main-thread/main-actor handoff (`MainActor.run`/main-thread dispatch) in all script command/property handlers; add guardrails for service-unavailable paths.

3. **Harden AppIntents output/privacy behavior.**
   Return full text in `value`, but use concise dialog summaries (length-limited, non-sensitive). Add truncation policy and explicit redaction option for history/search actions.

4. **Fix search semantics for history intent.**
   Query with predicate at fetch time (or paged search) instead of “latest 100 then filter”; keep result cap only on output, not input search domain.

5. **Improve file handling for transcription intent.**
   Switch temp naming to UUID-based filenames, sanitize extension handling, and avoid memory-heavy paths where possible for large files.

6. **Make vocabulary insertion idempotent at approval time.**
   Before each insert in `approve`/`approveAll`, re-check existing vocabulary (case-insensitive). If exists, mark suggestion approved without insertion or merge hints.

7. **Reconcile documentation with current product surface.**
   Update/remove MLX-specific docs and PR narrative; add migration note (“MLX provider removed, use Custom/Ollama path”).

8. **Add regression tests for new automation interfaces.**
   Add intent-level tests for mode transitions (`off/on/background`), search behavior, and output limits; add AppleScript integration smoke tests for command execution and property values.

9. **Add focused reviewability guardrails for future large churn commits.**
   Separate accessibility-ID-only changes from behavior changes in distinct commits/PRs to reduce regression risk and improve reviewer signal.
