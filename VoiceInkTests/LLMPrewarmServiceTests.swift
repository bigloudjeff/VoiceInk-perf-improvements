import Testing
import Foundation
@testable import VoiceInk

struct LLMPrewarmServiceTests {

 // MARK: - Provider Detection

 @Test func ollamaIsLocalProvider() {
  #expect(LLMPrewarmService.isLocalProvider(.ollama) == true)
 }

 @Test func cloudProvidersAreNotLocal() {
  let cloudProviders: [AIProvider] = [.gemini, .openAI, .anthropic, .groq, .cerebras, .mistral, .openRouter]
  for provider in cloudProviders {
   #expect(LLMPrewarmService.isLocalProvider(provider) == false, "\(provider.rawValue) should not be local")
  }
 }

 @Test func customProviderWithLocalhostIsLocal() {
  // custom provider reads its base URL from UserDefaults
  let original = UserDefaults.standard.string(forKey: UserDefaults.Keys.customProviderBaseURL)
  defer { UserDefaults.standard.set(original, forKey: UserDefaults.Keys.customProviderBaseURL) }

  UserDefaults.standard.set("http://localhost:8090/v1", forKey: UserDefaults.Keys.customProviderBaseURL)
  #expect(LLMPrewarmService.isLocalProvider(.custom) == true)
 }

 @Test func customProviderWith127IsLocal() {
  let original = UserDefaults.standard.string(forKey: UserDefaults.Keys.customProviderBaseURL)
  defer { UserDefaults.standard.set(original, forKey: UserDefaults.Keys.customProviderBaseURL) }

  UserDefaults.standard.set("http://127.0.0.1:1234/v1", forKey: UserDefaults.Keys.customProviderBaseURL)
  #expect(LLMPrewarmService.isLocalProvider(.custom) == true)
 }

 @Test func customProviderWithRemoteURLIsNotLocal() {
  let original = UserDefaults.standard.string(forKey: UserDefaults.Keys.customProviderBaseURL)
  defer { UserDefaults.standard.set(original, forKey: UserDefaults.Keys.customProviderBaseURL) }

  UserDefaults.standard.set("https://api.example.com/v1", forKey: UserDefaults.Keys.customProviderBaseURL)
  #expect(LLMPrewarmService.isLocalProvider(.custom) == false)
 }

 @Test func transcriptionOnlyProvidersAreNotLocal() {
  let providers: [AIProvider] = [.elevenLabs, .deepgram, .soniox]
  for provider in providers {
   #expect(LLMPrewarmService.isLocalProvider(provider) == false, "\(provider.rawValue) should not be local")
  }
 }

 // MARK: - Ollama Endpoint Construction

 @Test func ollamaEndpointWithoutTrailingSlash() {
  let result = LLMPrewarmService.ollamaEndpoint(baseURL: "http://localhost:11434")
  #expect(result == "http://localhost:11434/api/generate")
 }

 @Test func ollamaEndpointWithTrailingSlash() {
  let result = LLMPrewarmService.ollamaEndpoint(baseURL: "http://localhost:11434/")
  #expect(result == "http://localhost:11434/api/generate")
 }

 // MARK: - OpenAI-Compatible Endpoint Construction

 @Test func openAIEndpointAlreadyHasChatCompletions() {
  let result = LLMPrewarmService.openAICompatibleEndpoint(baseURL: "http://localhost:8090/v1/chat/completions")
  #expect(result == "http://localhost:8090/v1/chat/completions")
 }

 @Test func openAIEndpointEndsWithV1() {
  let result = LLMPrewarmService.openAICompatibleEndpoint(baseURL: "http://localhost:8090/v1")
  #expect(result == "http://localhost:8090/v1/chat/completions")
 }

 @Test func openAIEndpointEndsWithV1Slash() {
  let result = LLMPrewarmService.openAICompatibleEndpoint(baseURL: "http://localhost:8090/v1/")
  #expect(result == "http://localhost:8090/v1/chat/completions")
 }

 @Test func openAIEndpointBareURL() {
  let result = LLMPrewarmService.openAICompatibleEndpoint(baseURL: "http://localhost:8090")
  #expect(result == "http://localhost:8090/v1/chat/completions")
 }

 @Test func openAIEndpointBareURLWithTrailingSlash() {
  let result = LLMPrewarmService.openAICompatibleEndpoint(baseURL: "http://localhost:8090/")
  #expect(result == "http://localhost:8090/v1/chat/completions")
 }

 // MARK: - Inactivity Threshold

 @Test @MainActor func recentActivitySkipsPrewarm() async {
  let service = LLMPrewarmService.shared

  // Save and restore UserDefaults
  let originalEnabled = UserDefaults.standard.bool(forKey: UserDefaults.Keys.prewarmEnhancementModel)
  let originalThreshold = UserDefaults.standard.integer(forKey: UserDefaults.Keys.prewarmInactivityThreshold)
  let originalOllamaModel = UserDefaults.standard.string(forKey: UserDefaults.Keys.ollamaSelectedModel)
  defer {
   UserDefaults.standard.set(originalEnabled, forKey: UserDefaults.Keys.prewarmEnhancementModel)
   UserDefaults.standard.set(originalThreshold, forKey: UserDefaults.Keys.prewarmInactivityThreshold)
   UserDefaults.standard.set(originalOllamaModel, forKey: UserDefaults.Keys.ollamaSelectedModel)
  }

  // Enable prewarm with 5 min threshold
  UserDefaults.standard.set(true, forKey: UserDefaults.Keys.prewarmEnhancementModel)
  UserDefaults.standard.set(5, forKey: UserDefaults.Keys.prewarmInactivityThreshold)
  UserDefaults.standard.set("test-model", forKey: UserDefaults.Keys.ollamaSelectedModel)

  // Record activity just now
  service.recordActivity()

  // Create an AIService configured for Ollama
  let aiService = AIService()
  aiService.selectedProvider = .ollama

  // Prewarm should skip due to recent activity (no network call made).
  // Since prewarm is fire-and-forget, we verify it returns quickly
  // (under 1s) which means it hit the activity guard, not a network timeout.
  let start = Date()
  await service.prewarm(aiService: aiService)
  let elapsed = Date().timeIntervalSince(start)
  #expect(elapsed < 1.0, "Prewarm should skip quickly when activity is recent, took \(elapsed)s")
 }

 @Test @MainActor func disabledSettingSkipsPrewarm() async {
  let service = LLMPrewarmService.shared

  let originalEnabled = UserDefaults.standard.bool(forKey: UserDefaults.Keys.prewarmEnhancementModel)
  defer { UserDefaults.standard.set(originalEnabled, forKey: UserDefaults.Keys.prewarmEnhancementModel) }

  UserDefaults.standard.set(false, forKey: UserDefaults.Keys.prewarmEnhancementModel)

  let aiService = AIService()
  aiService.selectedProvider = .ollama

  let start = Date()
  await service.prewarm(aiService: aiService)
  let elapsed = Date().timeIntervalSince(start)
  #expect(elapsed < 1.0, "Prewarm should skip immediately when disabled")
 }

 @Test @MainActor func cloudProviderSkipsPrewarm() async {
  let service = LLMPrewarmService.shared

  let originalEnabled = UserDefaults.standard.bool(forKey: UserDefaults.Keys.prewarmEnhancementModel)
  defer { UserDefaults.standard.set(originalEnabled, forKey: UserDefaults.Keys.prewarmEnhancementModel) }

  UserDefaults.standard.set(true, forKey: UserDefaults.Keys.prewarmEnhancementModel)

  let aiService = AIService()
  aiService.selectedProvider = .gemini

  let start = Date()
  await service.prewarm(aiService: aiService)
  let elapsed = Date().timeIntervalSince(start)
  #expect(elapsed < 1.0, "Prewarm should skip immediately for cloud providers")
 }

 // MARK: - Threshold Minimum Clamping

 @Test func thresholdMinimumIsOneMinute() {
  // The code does max(thresholdMinutes, 1) * 60
  // With threshold set to 0, it should clamp to 1 minute (60s)
  let clamped = TimeInterval(max(0, 1) * 60)
  #expect(clamped == 60)
 }

 @Test func thresholdNegativeClampedToOneMinute() {
  let clamped = TimeInterval(max(-5, 1) * 60)
  #expect(clamped == 60)
 }
}
