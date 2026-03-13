import SwiftUI
import Cocoa
import KeyboardShortcuts
import LaunchAtLogin
import AVFoundation

struct SettingsView: View {
    @EnvironmentObject private var updaterViewModel: UpdaterViewModel
    @EnvironmentObject private var menuBarManager: MenuBarManager
    @EnvironmentObject private var hotkeyManager: HotkeyManager
    @EnvironmentObject private var whisperState: WhisperState
    @EnvironmentObject private var enhancementService: AIEnhancementService
    @ObservedObject private var soundManager = SoundManager.shared
    @Bindable private var mediaController = MediaController.shared
    @Bindable private var playbackController = PlaybackController.shared
    @AppStorage(UserDefaults.Keys.hasCompletedOnboarding) private var hasCompletedOnboarding = true
    @AppStorage(UserDefaults.Keys.autoUpdateCheck) private var autoUpdateCheck = true
    @AppStorage(UserDefaults.Keys.enableAnnouncements) private var enableAnnouncements = true
    @State private var showResetOnboardingAlert = false

    var body: some View {
        Form {
            // MARK: - Build Info
            Section {
                HStack {
                    Text(BuildInfo.summary)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }

            // MARK: - Power Mode
            PowerModeSection()

            // MARK: - General
            Section("General") {
                Toggle("Hide Dock Icon", isOn: $menuBarManager.isMenuBarOnly)
                    .accessibilityIdentifier(AccessibilityID.Settings.toggleHideDockIcon)

                LaunchAtLogin.Toggle("Launch at Login")
                    .accessibilityIdentifier(AccessibilityID.Settings.toggleLaunchAtLogin)

                Toggle("Auto-check Updates", isOn: $autoUpdateCheck)
                    .accessibilityIdentifier(AccessibilityID.Settings.toggleAutoCheckUpdates)
                    .onChange(of: autoUpdateCheck) { _, newValue in
                        updaterViewModel.toggleAutoUpdates(newValue)
                    }

                Toggle("Show Announcements", isOn: $enableAnnouncements)
                    .accessibilityIdentifier(AccessibilityID.Settings.toggleShowAnnouncements)
                    .onChange(of: enableAnnouncements) { _, newValue in
                        if newValue {
                            AnnouncementsService.shared.start()
                        } else {
                            AnnouncementsService.shared.stop()
                        }
                    }

                HStack {
                    Button("Check for Updates") {
                        updaterViewModel.checkForUpdates()
                    }
                    .disabled(!updaterViewModel.canCheckForUpdates)
                    .accessibilityIdentifier(AccessibilityID.Settings.buttonCheckForUpdates)

                    Button("Reset Onboarding") {
                        showResetOnboardingAlert = true
                    }
                    .accessibilityIdentifier(AccessibilityID.Settings.buttonResetOnboarding)
                }
            }

            // MARK: - Privacy
            Section {
                AudioCleanupSettingsView()
            } header: {
                Text("Privacy")
            } footer: {
                Text("Control how VoiceInk handles your transcription data and audio recordings.")
            }

            // MARK: - URL Scheme
            URLSchemeAuthSection()

            // MARK: - Backup
            Section {
                LabeledContent("Export Settings") {
                    Button("Export") {
                        ImportExportService.shared.exportSettings(
                            enhancementService: enhancementService,
                            whisperPrompt: WhisperPrompt(),
                            hotkeyManager: hotkeyManager,
                            menuBarManager: menuBarManager,
                            mediaController: mediaController,
                            playbackController: playbackController,
                            soundManager: soundManager,
                            whisperState: whisperState
                        )
                    }
                    .accessibilityIdentifier(AccessibilityID.Settings.buttonExportSettings)
                }

                LabeledContent("Import Settings") {
                    Button("Import") {
                        ImportExportService.shared.importSettings(
                            enhancementService: enhancementService,
                            whisperPrompt: WhisperPrompt(),
                            hotkeyManager: hotkeyManager,
                            menuBarManager: menuBarManager,
                            mediaController: mediaController,
                            playbackController: playbackController,
                            soundManager: soundManager,
                            whisperState: whisperState
                        )
                    }
                    .accessibilityIdentifier(AccessibilityID.Settings.buttonImportSettings)
                }
            } header: {
                Text("Backup")
            } footer: {
                Text("Export or import all your settings, prompts, power modes, dictionary, custom models, and transcription history.")
            }

            // MARK: - Diagnostics
            Section("Diagnostics") {
                DiagnosticsSettingsView()
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background(Color(NSColor.controlBackgroundColor))
        .alert("Reset Onboarding", isPresented: $showResetOnboardingAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                DispatchQueue.main.async {
                    hasCompletedOnboarding = false
                }
            }
        } message: {
            Text("You'll see the introduction screens again the next time you launch the app.")
        }
    }
}

// MARK: - Expandable Settings Row (entire row clickable)

struct ExpandableSettingsRow<Content: View>: View {
    @Binding var isExpanded: Bool
    @Binding var isEnabled: Bool
    let label: String
    var infoMessage: String? = nil
    var infoURL: String? = nil
    @ViewBuilder let content: () -> Content

    @State private var isHandlingToggleChange = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main row - entire area is tappable
            HStack {
                Toggle(isOn: $isEnabled) {
                    HStack(spacing: 4) {
                        Text(label)
                        if let message = infoMessage {
                            if let url = infoURL {
                                InfoTip(message, learnMoreURL: url)
                            } else {
                                InfoTip(message)
                            }
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .rotationEffect(.degrees(isEnabled && isExpanded ? 90 : 0))
                    .opacity(isEnabled ? 1 : 0.4)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                guard !isHandlingToggleChange else { return }
                if isEnabled {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }
            }

            // Expanded content with proper spacing
            if isEnabled && isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    content()
                }
                .padding(.top, 12)
                .padding(.leading, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
        .onChange(of: isEnabled) { _, newValue in
            isHandlingToggleChange = true
            if newValue {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded = true
                }
            } else {
                isExpanded = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isHandlingToggleChange = false
            }
        }
    }
}

// MARK: - Power Mode Section

struct PowerModeSection: View {
    @ObservedObject private var powerModeManager = PowerModeManager.shared
    @AppStorage(UserDefaults.Keys.powerModeUIFlag) private var powerModeUIFlag = false
    @AppStorage(UserDefaults.Keys.powerModeAutoRestoreEnabled) private var powerModeAutoRestoreEnabled = false
    @State private var showDisableAlert = false
    @State private var isExpanded = false

    var body: some View {
        Section {
            ExpandableSettingsRow(
                isExpanded: $isExpanded,
                isEnabled: toggleBinding,
                label: "Power Mode",
                infoMessage: "Apply custom settings based on active app or website.",
                infoURL: "https://tryvoiceink.com/docs/power-mode"
            ) {
                Toggle(isOn: $powerModeAutoRestoreEnabled) {
                    HStack(spacing: 4) {
                        Text("Auto-Restore Preferences")
                        InfoTip("After each recording session, revert preferences to what was configured before Power Mode was activated.")
                    }
                }
            }
        } header: {
            Text("Power Mode")
        }
        .alert("Power Mode Still Active", isPresented: $showDisableAlert) {
            Button("Got it", role: .cancel) { }
        } message: {
            Text("Disable or remove your Power Modes first.")
        }
    }

    private var toggleBinding: Binding<Bool> {
        Binding(
            get: { powerModeUIFlag },
            set: { newValue in
                if newValue {
                    powerModeUIFlag = true
                } else if powerModeManager.configurations.allSatisfy({ !$0.isEnabled }) {
                    powerModeUIFlag = false
                } else {
                    showDisableAlert = true
                }
            }
        )
    }
}

// MARK: - URL Scheme Auth Section

struct URLSchemeAuthSection: View {
 @AppStorage(VoiceInkURLHandler.tokenKey) private var authToken = ""
 @State private var showCopied = false

 var body: some View {
  Section {
   if authToken.isEmpty {
    HStack {
     Text("No token set -- URL scheme is open to all apps")
      .font(.system(size: 12))
      .foregroundColor(.secondary)
     Spacer()
     Button("Generate Token") {
      authToken = generateToken()
     }
    }
   } else {
    HStack {
     Text(authToken)
      .font(.system(size: 11, design: .monospaced))
      .foregroundColor(.secondary)
      .lineLimit(1)
      .textSelection(.enabled)
     Spacer()
     Button(showCopied ? "Copied" : "Copy") {
      NSPasteboard.general.clearContents()
      NSPasteboard.general.setString(authToken, forType: .string)
      showCopied = true
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { showCopied = false }
     }
     .disabled(showCopied)
     Button("Regenerate") {
      authToken = generateToken()
     }
     Button("Remove") {
      authToken = ""
     }
    }
   }
  } header: {
   Text("URL Scheme Authentication")
  } footer: {
   Text("When set, mutating voiceink:// actions require ?token=<value>. Navigation and status remain open.")
  }
 }

 private func generateToken() -> String {
  var bytes = [UInt8](repeating: 0, count: 24)
  _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
  return Data(bytes).base64EncodedString()
   .replacingOccurrences(of: "+", with: "-")
   .replacingOccurrences(of: "/", with: "_")
   .replacingOccurrences(of: "=", with: "")
 }
}

// MARK: - Text Extension

extension Text {
    func settingsDescription() -> some View {
        self
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}
