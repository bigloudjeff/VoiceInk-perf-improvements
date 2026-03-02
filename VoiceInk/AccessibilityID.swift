import Foundation

/// Centralized accessibility identifiers for XCUITest automation.
/// Naming convention: `screen.elementType.specificName` (camelCase).
/// Only used with `.accessibilityIdentifier` -- not `.accessibilityLabel`.
enum AccessibilityID {

 // MARK: - Sidebar / ContentView

 enum Sidebar {
  static let list = "sidebar.list"
  static func navLink(_ viewType: String) -> String { "sidebar.navLink.\(viewType)" }
  static let navLinkDashboard = "sidebar.navLink.dashboard"
  static let navLinkTranscribeAudio = "sidebar.navLink.transcribeAudio"
  static let buttonHistory = "sidebar.button.history"
  static let navLinkModels = "sidebar.navLink.models"
  static let navLinkEnhancement = "sidebar.navLink.enhancement"
  static let navLinkPostProcessing = "sidebar.navLink.postProcessing"
  static let navLinkPowerMode = "sidebar.navLink.powerMode"
  static let navLinkPermissions = "sidebar.navLink.permissions"
  static let navLinkAudioInput = "sidebar.navLink.audioInput"
  static let navLinkDictionary = "sidebar.navLink.dictionary"
  static let navLinkSettings = "sidebar.navLink.settings"
  static let navLinkLicense = "sidebar.navLink.license"
 }

 // MARK: - Menu Bar

 enum MenuBar {
  static let buttonToggleRecorder = "menuBar.button.toggleRecorder"
  static let menuTranscriptionModel = "menuBar.menu.transcriptionModel"
  static let buttonManageModels = "menuBar.button.manageModels"
  static let toggleAIEnhancement = "menuBar.toggle.aiEnhancement"
  static let menuPrompt = "menuBar.menu.prompt"
  static let menuAIProvider = "menuBar.menu.aiProvider"
  static let menuAIModel = "menuBar.menu.aiModel"
  static let menuAudioInput = "menuBar.menu.audioInput"
  static let menuAdditional = "menuBar.menu.additional"
  static let buttonClipboardContext = "menuBar.button.clipboardContext"
  static let buttonContextAwareness = "menuBar.button.contextAwareness"
  static let buttonRetryLastTranscription = "menuBar.button.retryLastTranscription"
  static let buttonCopyLastTranscription = "menuBar.button.copyLastTranscription"
  static let buttonTypeLastTranscription = "menuBar.button.typeLastTranscription"
  static let buttonHistory = "menuBar.button.history"
  static let buttonSettings = "menuBar.button.settings"
  static let buttonToggleDockIcon = "menuBar.button.toggleDockIcon"
  static let toggleLaunchAtLogin = "menuBar.toggle.launchAtLogin"
  static let buttonCheckForUpdates = "menuBar.button.checkForUpdates"
  static let buttonHelpAndSupport = "menuBar.button.helpAndSupport"
  static let buttonQuit = "menuBar.button.quit"
 }

 // MARK: - Settings

 enum Settings {
  static let pickerHotkey1 = "settings.picker.hotkey1"
  static let pickerHotkey2 = "settings.picker.hotkey2"
  static let buttonAddSecondHotkey = "settings.button.addSecondHotkey"
  static let pickerRecordingMode = "settings.picker.recordingMode"
  static let toggleSoundFeedback = "settings.toggle.soundFeedback"
  static let toggleMuteAudio = "settings.toggle.muteAudio"
  static let toggleRestoreClipboard = "settings.toggle.restoreClipboard"
  static let pickerPasteMethod = "settings.picker.pasteMethod"
  static let pickerTypeOutDelay = "settings.picker.typeOutDelay"
  static let toggleWarnNoTextField = "settings.toggle.warnNoTextField"
  static let togglePowerMode = "settings.toggle.powerMode"
  static let togglePowerModeAutoRestore = "settings.toggle.powerModeAutoRestore"
  static let pickerRecorderStyle = "settings.picker.recorderStyle"
  static let pickerDisplay = "settings.picker.display"
  static let togglePauseMedia = "settings.toggle.pauseMedia"
  static let toggleHideDockIcon = "settings.toggle.hideDockIcon"
  static let toggleLaunchAtLogin = "settings.toggle.launchAtLogin"
  static let toggleAutoCheckUpdates = "settings.toggle.autoCheckUpdates"
  static let toggleShowAnnouncements = "settings.toggle.showAnnouncements"
  static let buttonCheckForUpdates = "settings.button.checkForUpdates"
  static let buttonResetOnboarding = "settings.button.resetOnboarding"
  static let buttonExportSettings = "settings.button.exportSettings"
  static let buttonImportSettings = "settings.button.importSettings"
  static let toggleMiddleClick = "settings.toggle.middleClick"
  static let toggleCustomCancel = "settings.toggle.customCancel"
 }

 // MARK: - Enhancement

 enum Enhancement {
  static let toggleAIEnhancement = "enhancement.toggle.aiEnhancement"
  static let toggleClipboardContext = "enhancement.toggle.clipboardContext"
  static let toggleScreenContext = "enhancement.toggle.screenContext"
  static let buttonAddPrompt = "enhancement.button.addPrompt"
  static let grid = "enhancement.grid.prompts"
  static let toggleShortcutsDisclosure = "enhancement.toggle.shortcutsDisclosure"
 }

 // MARK: - Post Processing

 enum PostProcessing {
  static let togglePostProcessing = "postProcessing.toggle.postProcessing"
  static let toggleVocabularyExtraction = "postProcessing.toggle.vocabularyExtraction"
  static let toggleAutoPhoneticHints = "postProcessing.toggle.autoPhoneticHints"
 }

 // MARK: - AI Models

 enum Models {
  static let labelDefaultModel = "models.label.defaultModel"
  static func filterTab(_ name: String) -> String { "models.tab.\(name)" }
  static let tabRecommended = "models.tab.recommended"
  static let tabLocal = "models.tab.local"
  static let tabCloud = "models.tab.cloud"
  static let tabCustom = "models.tab.custom"
  static let buttonSettings = "models.button.settings"
  static let buttonImportLocal = "models.button.importLocal"
  static func modelCard(_ name: String) -> String { "models.card.\(name)" }
 }

 // MARK: - Dictionary

 enum Dictionary {
  static let tabReplacements = "dictionary.tab.replacements"
  static let tabVocabulary = "dictionary.tab.vocabulary"
  static let tabSuggestions = "dictionary.tab.suggestions"
  static let buttonImport = "dictionary.button.import"
  static let buttonExport = "dictionary.button.export"
 }

 // MARK: - Vocabulary

 enum Vocabulary {
  static let fieldAddWord = "vocabulary.field.addWord"
  static let buttonAddWord = "vocabulary.button.addWord"
  static let buttonSort = "vocabulary.button.sort"
  static let buttonGenerateHints = "vocabulary.button.generateHints"
  static let list = "vocabulary.list"
 }

 // MARK: - Word Replacement

 enum WordReplacement {
  static let fieldOriginal = "wordReplacement.field.original"
  static let fieldReplacement = "wordReplacement.field.replacement"
  static let buttonAdd = "wordReplacement.button.add"
  static let buttonSortOriginal = "wordReplacement.button.sortOriginal"
  static let buttonSortReplacement = "wordReplacement.button.sortReplacement"
 }

 // MARK: - Vocabulary Suggestions

 enum Suggestions {
  static let buttonDismissAll = "suggestions.button.dismissAll"
  static let buttonAddAll = "suggestions.button.addAll"
  static func buttonApprove(_ id: String) -> String { "suggestions.button.approve.\(id)" }
  static func buttonDismiss(_ id: String) -> String { "suggestions.button.dismiss.\(id)" }
 }

 // MARK: - Transcription History

 enum History {
  static let fieldSearch = "history.field.search"
  static let menuPowerModeFilter = "history.menu.powerModeFilter"
  static let menuModelFilter = "history.menu.modelFilter"
  static let buttonClearFilters = "history.button.clearFilters"
  static let buttonToggleLeftSidebar = "history.button.toggleLeftSidebar"
  static let buttonToggleRightSidebar = "history.button.toggleRightSidebar"
  static let buttonSelectAll = "history.button.selectAll"
  static let buttonDeselectAll = "history.button.deselectAll"
  static let buttonAnalyze = "history.button.analyze"
  static let buttonExport = "history.button.export"
  static let buttonDelete = "history.button.delete"
  static let list = "history.list"
 }

 // MARK: - Audio Transcribe

 enum AudioTranscribe {
  static let zoneDropArea = "audioTranscribe.zone.dropArea"
  static let buttonChooseFile = "audioTranscribe.button.chooseFile"
  static let buttonStartTranscription = "audioTranscribe.button.startTranscription"
  static let buttonChooseDifferentFile = "audioTranscribe.button.chooseDifferentFile"
  static let toggleAIEnhancement = "audioTranscribe.toggle.aiEnhancement"
  static let pickerPrompt = "audioTranscribe.picker.prompt"
 }

 // MARK: - Permissions

 enum Permissions {
  static func card(_ name: String) -> String { "permissions.card.\(name)" }
  static func buttonGrant(_ name: String) -> String { "permissions.button.grant.\(name)" }
  static func buttonRefresh(_ name: String) -> String { "permissions.button.refresh.\(name)" }
  static func statusGranted(_ name: String) -> String { "permissions.status.granted.\(name)" }
 }

 // MARK: - License

 enum License {
  static let buttonUpgrade = "license.button.upgrade"
  static let fieldLicenseKey = "license.field.licenseKey"
  static let buttonActivate = "license.button.activate"
  static let buttonDeactivate = "license.button.deactivate"
  static let buttonManagePortal = "license.button.managePortal"
  static let buttonChangelog = "license.button.changelog"
  static let buttonDiscord = "license.button.discord"
  static let buttonEmailSupport = "license.button.emailSupport"
  static let buttonDocs = "license.button.docs"
  static let buttonTipJar = "license.button.tipJar"
 }

 // MARK: - Onboarding

 enum Onboarding {
  static let buttonGetStarted = "onboarding.button.getStarted"
  static let buttonSkipTour = "onboarding.button.skipTour"
 }

 // MARK: - Power Mode

 enum PowerMode {
  static let buttonAddPowerMode = "powerMode.button.addPowerMode"
  static let buttonReorder = "powerMode.button.reorder"
  static let grid = "powerMode.grid"
  static func card(_ name: String) -> String { "powerMode.card.\(name)" }
 }

 // MARK: - Power Mode Config

 enum PowerModeConfig {
  static let fieldName = "powerModeConfig.field.name"
  static let buttonEmoji = "powerModeConfig.button.emoji"
  static let toggleAIEnhancement = "powerModeConfig.toggle.aiEnhancement"
  static let toggleContextAwareness = "powerModeConfig.toggle.contextAwareness"
  static let toggleDefault = "powerModeConfig.toggle.default"
  static let toggleAutoSend = "powerModeConfig.toggle.autoSend"
  static let buttonSave = "powerModeConfig.button.save"
  static let buttonDelete = "powerModeConfig.button.delete"
 }

 // MARK: - Prompt Editor

 enum PromptEditor {
  static let fieldTitle = "promptEditor.field.title"
  static let fieldDescription = "promptEditor.field.description"
  static let editorInstructions = "promptEditor.editor.instructions"
  static let buttonIconPicker = "promptEditor.button.iconPicker"
  static let buttonCancel = "promptEditor.button.cancel"
  static let buttonSave = "promptEditor.button.save"
  static let buttonClose = "promptEditor.button.close"
  static let toggleUseSystemTemplate = "promptEditor.toggle.useSystemTemplate"
  static let menuTemplates = "promptEditor.menu.templates"
 }

 // MARK: - Recorder

 enum Recorder {
  static let buttonPrompt = "recorder.button.prompt"
  static let buttonPowerMode = "recorder.button.powerMode"
  static let buttonRecord = "recorder.button.record"
  static let statusDisplay = "recorder.status.display"
 }

 // MARK: - Common / Reusable

 enum Common {
  static let buttonCopy = "common.button.copy"
  static let buttonSave = "common.button.save"
 }

 // MARK: - Audio Input

 enum AudioInput {
  static func inputModeCard(_ mode: String) -> String { "audioInput.card.\(mode)" }
 }
}
