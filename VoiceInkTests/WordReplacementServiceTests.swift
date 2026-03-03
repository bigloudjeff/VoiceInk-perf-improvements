import Testing
@testable import VoiceInk

struct WordReplacementServiceTests {

 @Test func basicReplacement() {
  let pairs = [(originalText: "hello", replacementText: "hi")]
  let result = WordReplacementService.applyReplacements(to: "hello world", pairs: pairs)
  #expect(result == "hi world")
 }

 @Test func caseInsensitiveReplacement() {
  let pairs = [(originalText: "Hello", replacementText: "hi")]
  let result = WordReplacementService.applyReplacements(to: "HELLO world", pairs: pairs)
  #expect(result == "hi world")
 }

 @Test func commaSeparatedVariants() {
  let pairs = [(originalText: "hey, hi, yo", replacementText: "hello")]
  #expect(WordReplacementService.applyReplacements(to: "hey there", pairs: pairs) == "hello there")
  #expect(WordReplacementService.applyReplacements(to: "hi there", pairs: pairs) == "hello there")
  #expect(WordReplacementService.applyReplacements(to: "yo there", pairs: pairs) == "hello there")
 }

 @Test func wordBoundaryRespected() {
  let pairs = [(originalText: "cat", replacementText: "dog")]
  let result = WordReplacementService.applyReplacements(to: "the cat sat on a caterpillar", pairs: pairs)
  #expect(result == "the dog sat on a caterpillar")
 }

 @Test func multipleReplacements() {
  let pairs = [
   (originalText: "foo", replacementText: "bar"),
   (originalText: "baz", replacementText: "qux"),
  ]
  let result = WordReplacementService.applyReplacements(to: "foo and baz", pairs: pairs)
  #expect(result == "bar and qux")
 }

 @Test func emptyPairsReturnsOriginal() {
  let pairs: [(originalText: String, replacementText: String)] = []
  let result = WordReplacementService.applyReplacements(to: "unchanged", pairs: pairs)
  #expect(result == "unchanged")
 }

 @Test func emptyOriginalTextSkipped() {
  let pairs = [(originalText: ",,,", replacementText: "replaced")]
  let result = WordReplacementService.applyReplacements(to: "test text", pairs: pairs)
  #expect(result == "test text")
 }
}
