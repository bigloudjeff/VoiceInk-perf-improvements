import Foundation

enum SettingsSearchIndex {

 static func search(_ query: String) -> [SettingsSearchEntry] {
  guard !query.isEmpty else { return [] }
  return entries.filter { $0.matches(query) }
 }

 // MARK: - All Entries

 static let entries: [SettingsSearchEntry] = pipelineEntries
  + modelsEntries
  + dictionaryEntries
  + permissionsEntries
  + powerModeEntries
  + preferencesEntries

 // MARK: - Pipeline

 private static let pipelineEntries: [SettingsSearchEntry] = [
  // General
  SettingsSearchEntry(
   title: "Pipeline",
   pane: .pipeline,
   section: "Pipeline",
   keywords: ["pipeline", "stages", "flow", "transcription pipeline", "processing"]
  ),
  SettingsSearchEntry(
   title: "Live Preview",
   pane: .pipeline,
   section: "Pipeline",
   keywords: ["preview", "sample", "demo", "transformation"]
  ),
  // Stage 1: Recording
  SettingsSearchEntry(
   title: "Hotkey 1",
   pane: .pipeline,
   section: "Recording",
   keywords: ["shortcut", "hotkey", "keybinding", "record key", "keyboard"]
  ),
  SettingsSearchEntry(
   title: "Hotkey 2",
   pane: .pipeline,
   section: "Recording",
   keywords: ["shortcut", "hotkey", "keybinding", "second hotkey", "keyboard"]
  ),
  SettingsSearchEntry(
   title: "Recording Mode",
   pane: .pipeline,
   section: "Recording",
   keywords: ["hold", "toggle", "push to talk", "press and hold"]
  ),
  SettingsSearchEntry(
   title: "Sound Feedback",
   pane: .pipeline,
   section: "Recording",
   keywords: ["sound", "chime", "beep", "audio feedback", "notification sound"]
  ),
  SettingsSearchEntry(
   title: "Mute Audio",
   pane: .pipeline,
   section: "Recording",
   keywords: ["mute", "silent", "volume", "audio"]
  ),
  SettingsSearchEntry(
   title: "Pause Media",
   pane: .pipeline,
   section: "Recording",
   keywords: ["pause", "media", "music", "playback", "resume"]
  ),
  SettingsSearchEntry(
   title: "Recorder Style",
   pane: .pipeline,
   section: "Recording",
   keywords: ["recorder", "mini", "notch", "floating", "pill"]
  ),
  SettingsSearchEntry(
   title: "Display",
   pane: .pipeline,
   section: "Recording",
   keywords: ["display", "monitor", "screen"]
  ),
  SettingsSearchEntry(
   title: "Middle-Click to Record",
   pane: .pipeline,
   section: "Recording",
   keywords: ["middle click", "mouse"]
  ),
  SettingsSearchEntry(
   title: "Cancel Shortcut",
   pane: .pipeline,
   section: "Recording",
   keywords: ["cancel", "escape", "abort", "shortcut"]
  ),
  SettingsSearchEntry(
   title: "Input Mode",
   pane: .pipeline,
   section: "Recording -- Audio Input",
   keywords: ["input", "microphone", "audio", "system default", "custom", "prioritized"]
  ),
  SettingsSearchEntry(
   title: "Prioritized Devices",
   pane: .pipeline,
   section: "Recording -- Audio Input",
   keywords: ["priority", "device", "microphone", "airpods", "headset"]
  ),
  // Stage 2: Speech-to-Text
  SettingsSearchEntry(
   title: "Language",
   pane: .pipeline,
   section: "Speech-to-Text",
   keywords: ["language", "locale", "english", "spanish", "multilingual"]
  ),
  SettingsSearchEntry(
   title: "Output Format Prompt",
   pane: .pipeline,
   section: "Speech-to-Text",
   keywords: ["whisper", "prompt", "initial prompt", "context", "output format"]
  ),
  SettingsSearchEntry(
   title: "Voice Activity Detection",
   pane: .pipeline,
   section: "Speech-to-Text",
   keywords: ["vad", "voice activity", "silence", "detection", "energy"]
  ),
  SettingsSearchEntry(
   title: "Prewarm Model",
   pane: .pipeline,
   section: "Speech-to-Text",
   keywords: ["prewarm", "warm up", "preload", "model ready"]
  ),
  // Stage 3: Output Filters
  SettingsSearchEntry(
   title: "Output Filters",
   pane: .pipeline,
   section: "Output Filters",
   keywords: ["filter", "tag", "bracket", "cleanup", "remove"]
  ),
  SettingsSearchEntry(
   title: "Filler Word Removal",
   pane: .pipeline,
   section: "Output Filters",
   keywords: ["filler", "um", "uh", "like", "you know", "remove filler"]
  ),
  // Stage 4: Text Formatting
  SettingsSearchEntry(
   title: "Text Formatting",
   pane: .pipeline,
   section: "Text Formatting",
   keywords: ["formatting", "capitalization", "punctuation", "text format"]
  ),
  SettingsSearchEntry(
   title: "Trailing Space",
   pane: .pipeline,
   section: "Text Formatting",
   keywords: ["space", "trailing", "line break", "formatting"]
  ),
  SettingsSearchEntry(
   title: "Post Processing",
   pane: .pipeline,
   section: "Text Formatting",
   keywords: ["post processing", "background enhancement", "vocabulary extraction"]
  ),
  // Stage 6: AI Enhancement
  SettingsSearchEntry(
   title: "AI Enhancement",
   pane: .pipeline,
   section: "AI Enhancement",
   keywords: ["ai", "enhance", "llm", "improve", "rewrite"]
  ),
  SettingsSearchEntry(
   title: "Clipboard Context",
   pane: .pipeline,
   section: "AI Enhancement",
   keywords: ["clipboard", "context", "copy", "paste context"]
  ),
  SettingsSearchEntry(
   title: "Screen Context",
   pane: .pipeline,
   section: "AI Enhancement",
   keywords: ["screen", "context", "ocr", "screen capture", "vision"]
  ),
  SettingsSearchEntry(
   title: "AI Provider",
   pane: .pipeline,
   section: "AI Enhancement",
   keywords: ["provider", "openai", "anthropic", "gemini", "groq", "cerebras", "ollama", "mlx", "local"]
  ),
  SettingsSearchEntry(
   title: "Enhancement Prompts",
   pane: .pipeline,
   section: "AI Enhancement",
   keywords: ["prompt", "template", "instruction", "custom prompt"]
  ),
  SettingsSearchEntry(
   title: "Prewarm Enhancement Model",
   pane: .pipeline,
   section: "AI Enhancement",
   keywords: ["prewarm", "warm up", "preload", "ollama", "mlx", "local model"]
  ),
  // Stage 7: Paste / Output
  SettingsSearchEntry(
   title: "Paste Method",
   pane: .pipeline,
   section: "Paste / Output",
   keywords: ["paste", "type out", "clipboard", "insert text", "applescript"]
  ),
  SettingsSearchEntry(
   title: "Restore Clipboard After Paste",
   pane: .pipeline,
   section: "Paste / Output",
   keywords: ["clipboard", "restore", "paste", "copy"]
  ),
  SettingsSearchEntry(
   title: "Warn No Text Field",
   pane: .pipeline,
   section: "Paste / Output",
   keywords: ["warn", "text field", "cursor", "focus"]
  ),
 ]

 // MARK: - AI Models

 private static let modelsEntries: [SettingsSearchEntry] = [
  SettingsSearchEntry(
   title: "Default Transcription Model",
   pane: .pipeline,
   section: "Speech-to-Text",
   keywords: ["model", "whisper", "transcription", "default model", "parakeet", "deepgram"]
  ),
 ]

 // MARK: - Dictionary

 private static let dictionaryEntries: [SettingsSearchEntry] = [
  SettingsSearchEntry(
   title: "Vocabulary",
   pane: .pipeline,
   section: "Word Replacement",
   keywords: ["vocabulary", "words", "custom words", "dictionary"]
  ),
  SettingsSearchEntry(
   title: "Word Replacements",
   pane: .pipeline,
   section: "Word Replacement",
   keywords: ["replacement", "substitution", "replace word", "autocorrect"]
  ),
  SettingsSearchEntry(
   title: "Vocabulary Suggestions",
   pane: .pipeline,
   section: "Word Replacement",
   keywords: ["suggestions", "recommended", "ai suggestions"]
  ),
 ]

 // MARK: - Permissions

 private static let permissionsEntries: [SettingsSearchEntry] = [
  SettingsSearchEntry(
   title: "Microphone Permission",
   pane: .permissions,
   section: "Permissions",
   keywords: ["microphone", "permission", "access", "privacy"]
  ),
  SettingsSearchEntry(
   title: "Accessibility Permission",
   pane: .permissions,
   section: "Permissions",
   keywords: ["accessibility", "permission", "access", "a11y"]
  ),
  SettingsSearchEntry(
   title: "Screen Recording Permission",
   pane: .permissions,
   section: "Permissions",
   keywords: ["screen recording", "permission", "capture", "screen"]
  ),
  SettingsSearchEntry(
   title: "Keyboard Shortcut Permission",
   pane: .permissions,
   section: "Permissions",
   keywords: ["keyboard", "shortcut", "permission", "hotkey"]
  ),
 ]

 // MARK: - Power Mode

 private static let powerModeEntries: [SettingsSearchEntry] = [
  SettingsSearchEntry(
   title: "Power Mode Configurations",
   pane: .powerMode,
   section: "Power Mode",
   keywords: ["power mode", "per-app", "configuration", "app-specific", "override"]
  ),
 ]

 // MARK: - Preferences

 private static let preferencesEntries: [SettingsSearchEntry] = [
  SettingsSearchEntry(
   title: "Hide Dock Icon",
   pane: .settings,
   section: "Preferences",
   keywords: ["dock", "icon", "menu bar only", "hide"]
  ),
  SettingsSearchEntry(
   title: "Launch at Login",
   pane: .settings,
   section: "Preferences",
   keywords: ["launch", "login", "startup", "start"]
  ),
  SettingsSearchEntry(
   title: "Auto-Check for Updates",
   pane: .settings,
   section: "Preferences",
   keywords: ["update", "sparkle", "auto update", "check updates"]
  ),
  SettingsSearchEntry(
   title: "Export Settings",
   pane: .settings,
   section: "Preferences -- Backup",
   keywords: ["export", "backup", "save settings"]
  ),
  SettingsSearchEntry(
   title: "Import Settings",
   pane: .settings,
   section: "Preferences -- Backup",
   keywords: ["import", "restore", "load settings"]
  ),
  SettingsSearchEntry(
   title: "Audio Cleanup",
   pane: .settings,
   section: "Preferences -- Privacy",
   keywords: ["audio", "cleanup", "delete recordings", "privacy"]
  ),
  SettingsSearchEntry(
   title: "Power Mode",
   pane: .settings,
   section: "Preferences",
   keywords: ["power mode", "per-app", "application override"]
  ),
 ]
}
