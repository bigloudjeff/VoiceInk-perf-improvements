import Testing
import Foundation
@testable import VoiceInk

struct PowerModeValidatorTests {

 @Test func emptyNameFails() {
  let manager = PowerModeManager.shared
  let validator = PowerModeValidator(powerModeManager: manager)
  let config = PowerModeConfig(name: "", emoji: "T", isAIEnhancementEnabled: false)

  let errors = validator.validateForSave(config: config, mode: .add)
  #expect(errors.contains { if case .emptyName = $0 { return true }; return false })
 }

 @Test func whitespaceOnlyNameFails() {
  let manager = PowerModeManager.shared
  let validator = PowerModeValidator(powerModeManager: manager)
  let config = PowerModeConfig(name: "   ", emoji: "T", isAIEnhancementEnabled: false)

  let errors = validator.validateForSave(config: config, mode: .add)
  #expect(errors.contains { if case .emptyName = $0 { return true }; return false })
 }

 @Test func validNamePasses() {
  let manager = PowerModeManager.shared
  let validator = PowerModeValidator(powerModeManager: manager)
  let config = PowerModeConfig(name: "UniqueTestName_\(UUID().uuidString)", emoji: "T", isAIEnhancementEnabled: false)

  let errors = validator.validateForSave(config: config, mode: .add)
  #expect(!errors.contains { if case .emptyName = $0 { return true }; return false })
 }
}
