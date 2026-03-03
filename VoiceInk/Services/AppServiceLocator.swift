import Foundation
import SwiftData

@MainActor
final class AppServiceLocator {
 static let shared = AppServiceLocator()

 private(set) var whisperState: WhisperState?
 private(set) var enhancementService: AIEnhancementService?
 private(set) var modelContainer: ModelContainer?
 private(set) var menuBarManager: MenuBarManager?

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
 }
}
