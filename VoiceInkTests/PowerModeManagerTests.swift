import Testing
@testable import VoiceInk

struct PowerModeManagerTests {

 @Test func cleanURLRemovesHttps() {
  #expect(PowerModeManager.cleanURL("https://example.com") == "example.com")
 }

 @Test func cleanURLRemovesHttp() {
  #expect(PowerModeManager.cleanURL("http://example.com") == "example.com")
 }

 @Test func cleanURLRemovesWww() {
  #expect(PowerModeManager.cleanURL("https://www.example.com") == "example.com")
 }

 @Test func cleanURLLowercases() {
  #expect(PowerModeManager.cleanURL("HTTPS://WWW.EXAMPLE.COM") == "example.com")
 }

 @Test func cleanURLPreservesPath() {
  #expect(PowerModeManager.cleanURL("https://example.com/path/page") == "example.com/path/page")
 }

 @Test func cleanURLTrimsWhitespace() {
  #expect(PowerModeManager.cleanURL("  https://example.com  ") == "example.com")
 }

 @Test func cleanURLHandlesPlainDomain() {
  #expect(PowerModeManager.cleanURL("example.com") == "example.com")
 }
}
