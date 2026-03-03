import AppIntents
import Foundation

struct DeactivatePowerModeIntent: AppIntent {
 static var title: LocalizedStringResource = "Deactivate VoiceInk Power Mode"
 static var description = IntentDescription("Deactivate the currently active Power Mode and restore previous settings.")

 static var openAppWhenRun: Bool = false

 @MainActor
 func perform() async throws -> some IntentResult & ProvidesDialog {
  let locator = AppServiceLocator.shared
  let sessionManager = PowerModeSessionManager.shared

  guard sessionManager.hasActiveSession else {
   return .result(dialog: "No Power Mode is currently active")
  }

  guard let whisperState = locator.whisperState,
        let enhancementService = locator.enhancementService else {
   throw IntentError.serviceNotAvailable
  }

  sessionManager.configure(whisperState: whisperState, enhancementService: enhancementService)
  await sessionManager.endSession()
  locator.powerModeProvider?.setActiveConfiguration(nil)

  return .result(dialog: "Power Mode deactivated")
 }
}
