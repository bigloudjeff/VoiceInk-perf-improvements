import Testing
@testable import VoiceInk

struct AIEnhancementOutputFilterTests {

 @Test func removesThinkingTags() {
  let input = "<thinking>some reasoning</thinking>Final answer"
  #expect(AIEnhancementOutputFilter.filter(input) == "Final answer")
 }

 @Test func removesThinkTags() {
  let input = "<think>internal thought</think>Output text"
  #expect(AIEnhancementOutputFilter.filter(input) == "Output text")
 }

 @Test func removesReasoningTags() {
  let input = "<reasoning>step by step</reasoning>Result"
  #expect(AIEnhancementOutputFilter.filter(input) == "Result")
 }

 @Test func handlesMultipleTags() {
  let input = "<thinking>a</thinking>Hello <think>b</think>World"
  #expect(AIEnhancementOutputFilter.filter(input) == "Hello World")
 }

 @Test func preservesTextWithoutTags() {
  let input = "Just normal text here"
  #expect(AIEnhancementOutputFilter.filter(input) == "Just normal text here")
 }

 @Test func handlesEmptyString() {
  #expect(AIEnhancementOutputFilter.filter("") == "")
 }

 @Test func handlesMultilineTagContent() {
  let input = """
  <thinking>
  Line 1
  Line 2
  </thinking>
  Clean output
  """
  #expect(AIEnhancementOutputFilter.filter(input) == "Clean output")
 }
}
