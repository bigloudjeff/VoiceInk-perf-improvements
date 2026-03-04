import Foundation
import os

@MainActor
final class LLMPrewarmService {
 static let shared = LLMPrewarmService()

 private let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "LLMPrewarm")
 private var lastActivityTime: Date?

 private init() {}

 /// Record that the LLM was just used (e.g. enhancement completed).
 /// Resets the inactivity timer so the next recording start can skip prewarming.
 func recordActivity() {
  lastActivityTime = Date()
 }

 /// Sends a minimal request to force the enhancement LLM to load.
 /// Fire-and-forget: errors are logged, never thrown.
 func prewarm(aiService: AIService) async {
  guard UserDefaults.standard.bool(forKey: UserDefaults.Keys.prewarmEnhancementModel) else {
   return
  }

  let provider = aiService.selectedProvider
  guard Self.isLocalProvider(provider) else {
   logger.debug("Skipping LLM prewarm - \(provider.rawValue, privacy: .public) is not a local provider")
   return
  }

  let thresholdMinutes = UserDefaults.standard.integer(forKey: UserDefaults.Keys.prewarmInactivityThreshold)
  let threshold = TimeInterval(max(thresholdMinutes, 1) * 60)

  if let last = lastActivityTime, Date().timeIntervalSince(last) < threshold {
   let elapsed = Int(Date().timeIntervalSince(last))
   logger.debug("Skipping LLM prewarm - model was active \(elapsed)s ago (threshold: \(Int(threshold))s)")
   return
  }
  let model = aiService.currentModel
  let baseURL = provider.baseURL

  logger.notice("Prewarming LLM: \(provider.rawValue, privacy: .public) model=\(model, privacy: .public)")

  let task = Task.detached(priority: .utility) { [logger] in
   do {
    switch provider {
    case .ollama:
     try await Self.prewarmOllama(baseURL: baseURL, model: model, logger: logger)
    default:
     try await Self.prewarmOpenAICompatible(baseURL: baseURL, model: model, logger: logger)
    }
    logger.notice("LLM prewarm completed successfully")
   } catch {
    logger.warning("LLM prewarm failed: \(error.localizedDescription, privacy: .public)")
   }
  }

  // Fire-and-forget with 10s timeout
  Task.detached {
   try? await Task.sleep(for: .seconds(10))
   task.cancel()
  }
 }

 // MARK: - Provider Detection

 nonisolated static func isLocalProvider(_ provider: AIProvider) -> Bool {
  switch provider {
  case .ollama:
   return true
  case .custom:
   let url = provider.baseURL.lowercased()
   return url.contains("localhost") || url.contains("127.0.0.1")
  default:
   return false
  }
 }

 // MARK: - Prewarm Requests

 nonisolated static func ollamaEndpoint(baseURL: String) -> String {
  baseURL.hasSuffix("/") ? "\(baseURL)api/generate" : "\(baseURL)/api/generate"
 }

 nonisolated static func openAICompatibleEndpoint(baseURL: String) -> String {
  if baseURL.hasSuffix("/chat/completions") {
   return baseURL
  } else if baseURL.hasSuffix("/v1") {
   return "\(baseURL)/chat/completions"
  } else if baseURL.hasSuffix("/v1/") {
   return "\(baseURL)chat/completions"
  } else {
   let trimmed = baseURL.hasSuffix("/") ? String(baseURL.dropLast()) : baseURL
   return "\(trimmed)/v1/chat/completions"
  }
 }

 private static func prewarmOllama(baseURL: String, model: String, logger: Logger) async throws {
  let urlString = ollamaEndpoint(baseURL: baseURL)
  guard let url = URL(string: urlString) else {
   logger.warning("Invalid Ollama base URL: \(baseURL, privacy: .public)")
   return
  }

  var request = URLRequest(url: url, timeoutInterval: 10)
  request.httpMethod = "POST"
  request.setValue("application/json", forHTTPHeaderField: "Content-Type")

  let body: [String: Any] = [
   "model": model,
   "prompt": "hi",
   "options": ["num_predict": 1]
  ]
  request.httpBody = try JSONSerialization.data(withJSONObject: body)

  let (_, response) = try await URLSession.shared.data(for: request)
  if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
   logger.warning("Ollama prewarm returned HTTP \(httpResponse.statusCode)")
  }
 }

 private static func prewarmOpenAICompatible(baseURL: String, model: String, logger: Logger) async throws {
  let urlString = openAICompatibleEndpoint(baseURL: baseURL)

  guard let url = URL(string: urlString) else {
   logger.warning("Invalid custom provider base URL: \(baseURL, privacy: .public)")
   return
  }

  var request = URLRequest(url: url, timeoutInterval: 10)
  request.httpMethod = "POST"
  request.setValue("application/json", forHTTPHeaderField: "Content-Type")

  let body: [String: Any] = [
   "model": model,
   "messages": [["role": "user", "content": "hi"]],
   "max_tokens": 1
  ]
  request.httpBody = try JSONSerialization.data(withJSONObject: body)

  let (_, response) = try await URLSession.shared.data(for: request)
  if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
   logger.warning("Custom provider prewarm returned HTTP \(httpResponse.statusCode)")
  }
 }
}
