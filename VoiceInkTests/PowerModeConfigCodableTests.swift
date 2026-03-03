import Testing
import Foundation
@testable import VoiceInk

struct PowerModeConfigCodableTests {

 @Test func roundTripEncodeDecode() throws {
  let config = PowerModeConfig(
   name: "Test",
   emoji: "T",
   isAIEnhancementEnabled: true,
   selectedPrompt: "Default",
   selectedTranscriptionModelName: "whisper-large",
   useScreenCapture: true,
   isAutoSendEnabled: false,
   isEnabled: true,
   isDefault: false
  )

  let data = try JSONEncoder().encode(config)
  let decoded = try JSONDecoder().decode(PowerModeConfig.self, from: data)

  #expect(decoded.id == config.id)
  #expect(decoded.name == config.name)
  #expect(decoded.emoji == config.emoji)
  #expect(decoded.isAIEnhancementEnabled == config.isAIEnhancementEnabled)
  #expect(decoded.selectedPrompt == config.selectedPrompt)
  #expect(decoded.selectedTranscriptionModelName == config.selectedTranscriptionModelName)
  #expect(decoded.useScreenCapture == config.useScreenCapture)
  #expect(decoded.isAutoSendEnabled == config.isAutoSendEnabled)
  #expect(decoded.isEnabled == config.isEnabled)
  #expect(decoded.isDefault == config.isDefault)
 }

 @Test func decodesLegacyWhisperModelKey() throws {
  // Simulate JSON with the old "selectedWhisperModel" key
  let json = """
  {
   "id": "11111111-1111-1111-1111-111111111111",
   "name": "Legacy",
   "emoji": "L",
   "isAIEnhancementEnabled": false,
   "selectedWhisperModel": "ggml-base.en",
   "useScreenCapture": false,
   "isAutoSendEnabled": false,
   "isEnabled": true,
   "isDefault": false
  }
  """
  let data = Data(json.utf8)
  let decoded = try JSONDecoder().decode(PowerModeConfig.self, from: data)

  #expect(decoded.selectedTranscriptionModelName == "ggml-base.en")
  #expect(decoded.name == "Legacy")
 }

 @Test func defaultsForOptionalFields() throws {
  let json = """
  {
   "id": "22222222-2222-2222-2222-222222222222",
   "name": "Minimal",
   "emoji": "M",
   "isAIEnhancementEnabled": false,
   "useScreenCapture": false,
   "isAutoSendEnabled": false,
   "isEnabled": true,
   "isDefault": false
  }
  """
  let data = Data(json.utf8)
  let decoded = try JSONDecoder().decode(PowerModeConfig.self, from: data)

  #expect(decoded.selectedPrompt == nil)
  #expect(decoded.selectedTranscriptionModelName == nil)
  #expect(decoded.selectedLanguage == nil)
  #expect(decoded.selectedAIProvider == nil)
  #expect(decoded.selectedAIModel == nil)
  #expect(decoded.appConfigs == nil)
  #expect(decoded.urlConfigs == nil)
 }

 @Test func equalityByIdOnly() {
  let id = UUID()
  let a = PowerModeConfig(id: id, name: "A", emoji: "1", isAIEnhancementEnabled: false)
  let b = PowerModeConfig(id: id, name: "B", emoji: "2", isAIEnhancementEnabled: true)
  #expect(a == b)
 }
}
