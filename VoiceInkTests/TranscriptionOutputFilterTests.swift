import Testing
@testable import VoiceInk

struct TranscriptionOutputFilterTests {

 @Test func removesXMLTags() {
  let input = "<caption>some text</caption> Hello world"
  let result = TranscriptionOutputFilter.filter(input)
  #expect(result == "Hello world")
 }

 @Test func removesBracketedHallucinations() {
  let input = "Hello [music playing] world"
  let result = TranscriptionOutputFilter.filter(input)
  #expect(result == "Hello world")
 }

 @Test func removesParenthesizedHallucinations() {
  let input = "Hello (laughter) world"
  let result = TranscriptionOutputFilter.filter(input)
  #expect(result == "Hello world")
 }

 @Test func removesCurlyBracketHallucinations() {
  let input = "Hello {applause} world"
  let result = TranscriptionOutputFilter.filter(input)
  #expect(result == "Hello world")
 }

 @Test func collapsesExcessiveWhitespace() {
  let input = "Hello   world   test"
  let result = TranscriptionOutputFilter.filter(input)
  #expect(result == "Hello world test")
 }

 @Test func preservesCleanText() {
  let input = "This is clean text."
  #expect(TranscriptionOutputFilter.filter(input) == "This is clean text.")
 }

 @Test func handlesEmptyString() {
  #expect(TranscriptionOutputFilter.filter("") == "")
 }

 @Test func trimLeadingTrailingWhitespace() {
  let input = "  Hello world  "
  #expect(TranscriptionOutputFilter.filter(input) == "Hello world")
 }

 @Test func handlesMultipleXMLTags() {
  let input = "<tag1>a</tag1> Hello <tag2>b</tag2> world"
  let result = TranscriptionOutputFilter.filter(input)
  #expect(result == "Hello world")
 }
}
