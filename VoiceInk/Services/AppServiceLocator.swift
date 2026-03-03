import Foundation
import SwiftData

@MainActor
final class AppServiceLocator {
 static let shared = AppServiceLocator()

 private(set) var whisperState: WhisperState?
 private(set) var enhancementService: AIEnhancementService?
 private(set) var modelContainer: ModelContainer?
 private(set) var menuBarManager: MenuBarManager?

 private(set) var powerModeProvider: (any PowerModeProviding)?
 private(set) var apiKeyProvider: (any APIKeyProviding)?
 private(set) var soundPlayer: (any SoundPlaying)?
 private(set) var notificationPresenter: (any NotificationPresenting)?
 private(set) var wordReplacer: (any WordReplacing)?

 private init() {}

 func configure(
  whisperState: WhisperState,
  enhancementService: AIEnhancementService,
  modelContainer: ModelContainer,
  menuBarManager: MenuBarManager? = nil
 ) {
  self.whisperState = whisperState
  self.enhancementService = enhancementService
  self.modelContainer = modelContainer
  if let menuBarManager { self.menuBarManager = menuBarManager }

  // Default protocol-typed providers to concrete singletons
  self.powerModeProvider = PowerModeManager.shared
  self.apiKeyProvider = APIKeyManager.shared
  self.soundPlayer = SoundManager.shared
  self.notificationPresenter = NotificationManager.shared
  self.wordReplacer = WordReplacementService.shared
 }
}
