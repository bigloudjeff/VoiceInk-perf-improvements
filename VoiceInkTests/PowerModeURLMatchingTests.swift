import Testing
import Foundation
@testable import VoiceInk

struct PowerModeURLMatchingTests {

 @Test func staticCleanURLMatchesInstance() {
  let url = "https://www.EXAMPLE.com/path"
  #expect(PowerModeManager.cleanURL(url) == "example.com/path")
 }

 @Test func matchURLFindsConfig() {
  var config = PowerModeConfig(name: "Test", emoji: "T", isAIEnhancementEnabled: false)
  config.isEnabled = true
  config.urlConfigs = [URLConfig(url: "example.com")]

  let result = PowerModeManager.matchURL("https://www.example.com/page", in: [config])
  #expect(result?.name == "Test")
 }

 @Test func matchURLReturnsNilForNoMatch() {
  var config = PowerModeConfig(name: "Test", emoji: "T", isAIEnhancementEnabled: false)
  config.isEnabled = true
  config.urlConfigs = [URLConfig(url: "example.com")]

  let result = PowerModeManager.matchURL("https://other.com", in: [config])
  #expect(result == nil)
 }

 @Test func matchURLSkipsDisabledConfigs() {
  var config = PowerModeConfig(name: "Test", emoji: "T", isAIEnhancementEnabled: false)
  config.isEnabled = false
  config.urlConfigs = [URLConfig(url: "example.com")]

  let result = PowerModeManager.matchURL("https://example.com", in: [config])
  #expect(result == nil)
 }

 @Test func matchURLChecksMultipleConfigs() {
  var config1 = PowerModeConfig(name: "First", emoji: "1", isAIEnhancementEnabled: false)
  config1.isEnabled = true
  config1.urlConfigs = [URLConfig(url: "first.com")]

  var config2 = PowerModeConfig(name: "Second", emoji: "2", isAIEnhancementEnabled: false)
  config2.isEnabled = true
  config2.urlConfigs = [URLConfig(url: "second.com")]

  let result = PowerModeManager.matchURL("https://second.com/page", in: [config1, config2])
  #expect(result?.name == "Second")
 }

 @Test func matchURLHandlesNilUrlConfigs() {
  var config = PowerModeConfig(name: "Test", emoji: "T", isAIEnhancementEnabled: false)
  config.isEnabled = true
  config.urlConfigs = nil

  let result = PowerModeManager.matchURL("https://example.com", in: [config])
  #expect(result == nil)
 }

 // MARK: - Domain boundary matching

 @Test func matchURLRejectsPartialDomainMatch() {
  var config = PowerModeConfig(name: "Test", emoji: "T", isAIEnhancementEnabled: false)
  config.isEnabled = true
  config.urlConfigs = [URLConfig(url: "example.com")]

  let result = PowerModeManager.matchURL("https://notexample.com", in: [config])
  #expect(result == nil)
 }

 @Test func matchURLRejectsDomainAsSubdomain() {
  var config = PowerModeConfig(name: "Test", emoji: "T", isAIEnhancementEnabled: false)
  config.isEnabled = true
  config.urlConfigs = [URLConfig(url: "example.com")]

  let result = PowerModeManager.matchURL("https://example.com.evil.com", in: [config])
  #expect(result == nil)
 }

 @Test func matchURLAllowsSubdomainMatch() {
  var config = PowerModeConfig(name: "Test", emoji: "T", isAIEnhancementEnabled: false)
  config.isEnabled = true
  config.urlConfigs = [URLConfig(url: "example.com")]

  let result = PowerModeManager.matchURL("https://sub.example.com/page", in: [config])
  #expect(result?.name == "Test")
 }

 @Test func matchURLExactDomainMatch() {
  var config = PowerModeConfig(name: "Test", emoji: "T", isAIEnhancementEnabled: false)
  config.isEnabled = true
  config.urlConfigs = [URLConfig(url: "example.com")]

  let result = PowerModeManager.matchURL("https://example.com", in: [config])
  #expect(result?.name == "Test")
 }
}
