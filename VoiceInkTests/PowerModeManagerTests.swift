import Testing
@testable import VoiceInk

struct PowerModeManagerTests {

 @Test func cleanURLRemovesHttps() {
  let manager = PowerModeManager.shared
  #expect(manager.cleanURL("https://example.com") == "example.com")
 }

 @Test func cleanURLRemovesHttp() {
  let manager = PowerModeManager.shared
  #expect(manager.cleanURL("http://example.com") == "example.com")
 }

 @Test func cleanURLRemovesWww() {
  let manager = PowerModeManager.shared
  #expect(manager.cleanURL("https://www.example.com") == "example.com")
 }

 @Test func cleanURLLowercases() {
  let manager = PowerModeManager.shared
  #expect(manager.cleanURL("HTTPS://WWW.EXAMPLE.COM") == "example.com")
 }

 @Test func cleanURLPreservesPath() {
  let manager = PowerModeManager.shared
  #expect(manager.cleanURL("https://example.com/path/page") == "example.com/path/page")
 }

 @Test func cleanURLTrimsWhitespace() {
  let manager = PowerModeManager.shared
  #expect(manager.cleanURL("  https://example.com  ") == "example.com")
 }

 @Test func cleanURLHandlesPlainDomain() {
  let manager = PowerModeManager.shared
  #expect(manager.cleanURL("example.com") == "example.com")
 }
}
