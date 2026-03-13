import Testing
@testable import VoiceInk

struct ReasoningConfigTests {

 @Test func geminiFlashReturnsLow() {
  #expect(ReasoningConfig.getReasoningParameter(for: "gemini-2.5-flash") == "low")
 }

 @Test func geminiFlashLiteReturnsLow() {
  #expect(ReasoningConfig.getReasoningParameter(for: "gemini-2.5-flash-lite") == "low")
 }

 @Test func openAIReasoningReturnsMinimal() {
  #expect(ReasoningConfig.getReasoningParameter(for: "gpt-5-mini") == "minimal")
  #expect(ReasoningConfig.getReasoningParameter(for: "gpt-5-nano") == "minimal")
 }

 @Test func cerebrasReasoningReturnsLow() {
  #expect(ReasoningConfig.getReasoningParameter(for: "gpt-oss-120b") == "low")
 }

 @Test func nonReasoningModelReturnsNil() {
  #expect(ReasoningConfig.getReasoningParameter(for: "gpt-4o") == nil)
  #expect(ReasoningConfig.getReasoningParameter(for: "claude-3-opus") == nil)
 }

 @Test func emptyStringReturnsNil() {
  #expect(ReasoningConfig.getReasoningParameter(for: "") == nil)
 }

 // MARK: - requiresFixedTemperature

 @Test func gpt5RequiresFixedTemperature() {
  #expect(ReasoningConfig.requiresFixedTemperature("gpt-5.2") == true)
  #expect(ReasoningConfig.requiresFixedTemperature("gpt-5.1") == true)
  #expect(ReasoningConfig.requiresFixedTemperature("gpt-5-mini") == true)
  #expect(ReasoningConfig.requiresFixedTemperature("gpt-5-nano") == true)
 }

 @Test func nonFixedTemperatureModels() {
  #expect(ReasoningConfig.requiresFixedTemperature("gpt-4o") == false)
  #expect(ReasoningConfig.requiresFixedTemperature("claude-3-opus") == false)
  #expect(ReasoningConfig.requiresFixedTemperature("") == false)
 }
}
