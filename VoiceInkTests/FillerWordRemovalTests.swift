import Testing
@testable import VoiceInk

struct FillerWordRemovalTests {

 @Test func removesFillerWords() {
  let result = TranscriptionOutputFilter.removeFillerWords(
   from: "I think um this is um good",
   isEnabled: true,
   fillerWords: ["um"]
  )
  #expect(result == "I think  this is  good")
 }

 @Test func disabledReturnsOriginal() {
  let result = TranscriptionOutputFilter.removeFillerWords(
   from: "um hello um world",
   isEnabled: false,
   fillerWords: ["um"]
  )
  #expect(result == "um hello um world")
 }

 @Test func emptyFillerWordsReturnsOriginal() {
  let result = TranscriptionOutputFilter.removeFillerWords(
   from: "hello world",
   isEnabled: true,
   fillerWords: []
  )
  #expect(result == "hello world")
 }

 @Test func removesTrailingCommaAfterFiller() {
  let result = TranscriptionOutputFilter.removeFillerWords(
   from: "well, I think so",
   isEnabled: true,
   fillerWords: ["well"]
  )
  #expect(result == " I think so")
 }

 @Test func caseInsensitive() {
  let result = TranscriptionOutputFilter.removeFillerWords(
   from: "UM hello Um world",
   isEnabled: true,
   fillerWords: ["um"]
  )
  #expect(result == " hello  world")
 }

 @Test func respectsWordBoundaries() {
  let result = TranscriptionOutputFilter.removeFillerWords(
   from: "umbrella is like a shelter",
   isEnabled: true,
   fillerWords: ["um", "like"]
  )
  #expect(result == "umbrella is  a shelter")
 }
}
