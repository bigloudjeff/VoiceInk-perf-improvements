import Testing
@testable import VoiceInk

struct WhisperTextFormatterTests {

 @Test func formatsShortTextUnchanged() {
  let input = "Hello world."
  let result = WhisperTextFormatter.format(input)
  #expect(result == "Hello world.")
 }

 @Test func handlesEmptyString() {
  #expect(WhisperTextFormatter.format("") == "")
 }

 @Test func chunksLongTextIntoParagraphs() {
  // Build a string with many sentences to trigger paragraph splitting
  let sentences = (1...20).map { "This is sentence number \($0) with enough words to count." }
  let input = sentences.joined(separator: " ")
  let result = WhisperTextFormatter.format(input)
  // Should contain paragraph breaks (double newlines)
  #expect(result.contains("\n\n"))
 }

 @Test func preservesSingleSentence() {
  let input = "A single sentence with several words."
  let result = WhisperTextFormatter.format(input)
  // Single sentence should not get split
  #expect(!result.contains("\n\n"))
 }
}
