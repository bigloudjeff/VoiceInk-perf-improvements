import Foundation

enum SettingsSearchIndex {

 static func search(_ query: String) -> [SettingsSearchEntry] {
  guard !query.isEmpty else { return [] }
  return entries.filter { $0.matches(query) }
 }

 // MARK: - All Entries

 static let entries: [SettingsSearchEntry] = settingsEntries
  + enhancementEntries
  + modelsEntries
  + postProcessingEntries
  + audioInputEntries
  + dictionaryEntries
  + permissionsEntries
  + powerModeEntries

 // MARK: - Settings

 private static let settingsEntries: [SettingsSearchEntry] = [
  SettingsSearchEntry(
   title: "Hotkey 1",
   pane: .settings,
   section: "Keyboard Shortcuts",
   keywords: ["shortcut", "hotkey", "keybinding", "record key", "keyboard"]
  ),
  SettingsSearchEntry(
   title: "Hotkey 2",
   pane: .settings,
   section: "Keyboard Shortcuts",
   keywords: ["shortcut", "hotkey", "keybinding", "second hotkey", "keyboard"]
  ),
  SettingsSearchEntry(
   title: "Recording Mode",
   pane: .settings,
   section: "Recording Mode",
   keywords: ["hold", "toggle", "push to talk", "press and hold"]
  ),
  SettingsSearchEntry(
   title: "Sound Feedback",
   pane: .settings,
   section: "Recording Feedback",
   keywords: ["sound", "chime", "beep", "audio feedback", "notification sound"]
  ),
  SettingsSearchEntry(
   title: "Mute Audio",
   pane: .settings,
   section: "Recording Feedback",
   keywords: ["mute", "silent", "volume", "audio"]
  ),
  SettingsSearchEntry(
   title: "Restore Clipboard After Paste",
   pane: .settings,
   section: "Interface",
   keywords: ["clipboard", "restore", "paste", "copy"]
  ),
  SettingsSearchEntry(
   title: "Paste Method",
   pane: .settings,
   section: "Interface",
   keywords: ["paste", "type out", "clipboard", "insert text"]
  ),
  SettingsSearchEntry(
   title: "Warn No Text Field",
   pane: .settings,
   section: "Interface",
   keywords: ["warn", "text field", "cursor", "focus"]
  ),
  SettingsSearchEntry(
   title: "Power Mode",
   pane: .settings,
   section: "Interface",
   keywords: ["power mode", "per-app", "application override"]
  ),
  SettingsSearchEntry(
   title: "Recorder Style",
   pane: .settings,
   section: "Interface",
   keywords: ["recorder", "mini", "notch", "floating", "pill"]
  ),
  SettingsSearchEntry(
   title: "Display",
   pane: .settings,
   section: "Interface",
   keywords: ["display", "monitor", "screen"]
  ),
  SettingsSearchEntry(
   title: "Pause Media",
   pane: .settings,
   section: "General Settings",
   keywords: ["pause", "media", "music", "playback", "resume"]
  ),
  SettingsSearchEntry(
   title: "Hide Dock Icon",
   pane: .settings,
   section: "General Settings",
   keywords: ["dock", "icon", "menu bar only", "hide"]
  ),
  SettingsSearchEntry(
   title: "Launch at Login",
   pane: .settings,
   section: "General Settings",
   keywords: ["launch", "login", "startup", "start"]
  ),
  SettingsSearchEntry(
   title: "Auto-Check for Updates",
   pane: .settings,
   section: "General Settings",
   keywords: ["update", "sparkle", "auto update", "check updates"]
  ),
  SettingsSearchEntry(
   title: "Export Settings",
   pane: .settings,
   section: "Backup",
   keywords: ["export", "backup", "save settings"]
  ),
  SettingsSearchEntry(
   title: "Import Settings",
   pane: .settings,
   section: "Backup",
   keywords: ["import", "restore", "load settings"]
  ),
  SettingsSearchEntry(
   title: "Middle-Click to Record",
   pane: .settings,
   section: "Experimental",
   keywords: ["middle click", "mouse", "experimental"]
  ),
  SettingsSearchEntry(
   title: "Cancel Shortcut",
   pane: .settings,
   section: "Experimental",
   keywords: ["cancel", "escape", "abort", "shortcut"]
  ),
  SettingsSearchEntry(
   title: "Audio Cleanup",
   pane: .settings,
   section: "Privacy",
   keywords: ["audio", "cleanup", "delete recordings", "privacy"]
  ),
 ]

 // MARK: - Enhancement

 private static let enhancementEntries: [SettingsSearchEntry] = [
  SettingsSearchEntry(
   title: "AI Enhancement",
   pane: .enhancement,
   section: "Enhancement",
   keywords: ["ai", "enhance", "llm", "improve", "rewrite"]
  ),
  SettingsSearchEntry(
   title: "Clipboard Context",
   pane: .enhancement,
   section: "Context",
   keywords: ["clipboard", "context", "copy", "paste context"]
  ),
  SettingsSearchEntry(
   title: "Screen Context",
   pane: .enhancement,
   section: "Context",
   keywords: ["screen", "context", "ocr", "screen capture", "vision"]
  ),
  SettingsSearchEntry(
   title: "AI Provider",
   pane: .enhancement,
   section: "Provider",
   keywords: ["provider", "openai", "anthropic", "gemini", "groq", "cerebras", "ollama", "mlx", "local"]
  ),
  SettingsSearchEntry(
   title: "Enhancement Prompts",
   pane: .enhancement,
   section: "Prompts",
   keywords: ["prompt", "template", "instruction", "custom prompt"]
  ),
  SettingsSearchEntry(
   title: "Prewarm Enhancement Model",
   pane: .enhancement,
   section: "Provider",
   keywords: ["prewarm", "warm up", "preload", "ollama", "mlx", "local model"]
  ),
 ]

 // MARK: - AI Models

 private static let modelsEntries: [SettingsSearchEntry] = [
  SettingsSearchEntry(
   title: "Default Transcription Model",
   pane: .models,
   section: "Model Selection",
   keywords: ["model", "whisper", "transcription", "default model", "parakeet", "deepgram"]
  ),
  SettingsSearchEntry(
   title: "Language",
   pane: .models,
   section: "Model Settings",
   keywords: ["language", "locale", "english", "spanish", "multilingual"]
  ),
  SettingsSearchEntry(
   title: "Whisper Prompt",
   pane: .models,
   section: "Model Settings",
   keywords: ["whisper", "prompt", "initial prompt", "context"]
  ),
  SettingsSearchEntry(
   title: "Add Space Between Lines",
   pane: .models,
   section: "Model Settings",
   keywords: ["space", "newline", "line break", "formatting"]
  ),
  SettingsSearchEntry(
   title: "Text Formatting",
   pane: .models,
   section: "Model Settings",
   keywords: ["formatting", "capitalization", "punctuation", "text format"]
  ),
  SettingsSearchEntry(
   title: "Voice Activity Detection",
   pane: .models,
   section: "Model Settings",
   keywords: ["vad", "voice activity", "silence", "detection", "energy"]
  ),
  SettingsSearchEntry(
   title: "Prewarm Model",
   pane: .models,
   section: "Model Settings",
   keywords: ["prewarm", "warm up", "preload", "model ready"]
  ),
  SettingsSearchEntry(
   title: "Filler Word Removal",
   pane: .models,
   section: "Model Settings",
   keywords: ["filler", "um", "uh", "like", "you know", "remove filler"]
  ),
 ]

 // MARK: - Post Processing

 private static let postProcessingEntries: [SettingsSearchEntry] = [
  SettingsSearchEntry(
   title: "Post Processing",
   pane: .postProcessing,
   section: "Post Processing",
   keywords: ["post processing", "after transcription", "processing"]
  ),
  SettingsSearchEntry(
   title: "Vocabulary Extraction",
   pane: .postProcessing,
   section: "Post Processing",
   keywords: ["vocabulary", "extract", "words", "dictionary"]
  ),
  SettingsSearchEntry(
   title: "Auto-Generate Phonetic Hints",
   pane: .postProcessing,
   section: "Post Processing",
   keywords: ["phonetic", "hints", "pronunciation", "auto generate"]
  ),
 ]

 // MARK: - Audio Input

 private static let audioInputEntries: [SettingsSearchEntry] = [
  SettingsSearchEntry(
   title: "Input Mode",
   pane: .audioInput,
   section: "Audio Input",
   keywords: ["input", "microphone", "audio", "system default", "custom", "prioritized"]
  ),
  SettingsSearchEntry(
   title: "Prioritized Devices",
   pane: .audioInput,
   section: "Audio Input",
   keywords: ["priority", "device", "microphone", "airpods", "headset"]
  ),
 ]

 // MARK: - Dictionary

 private static let dictionaryEntries: [SettingsSearchEntry] = [
  SettingsSearchEntry(
   title: "Vocabulary",
   pane: .dictionary,
   section: "Dictionary",
   keywords: ["vocabulary", "words", "custom words", "dictionary"]
  ),
  SettingsSearchEntry(
   title: "Word Replacements",
   pane: .dictionary,
   section: "Dictionary",
   keywords: ["replacement", "substitution", "replace word", "autocorrect"]
  ),
  SettingsSearchEntry(
   title: "Vocabulary Suggestions",
   pane: .dictionary,
   section: "Dictionary",
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
}
