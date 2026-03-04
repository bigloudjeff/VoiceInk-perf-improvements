import Foundation
import SwiftData
import os
import AppKit

@MainActor
final class ModelPrewarmService: ObservableObject {
 private let contextProvider: any WhisperContextProvider
 private let modelContext: ModelContext
 private let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "ModelPrewarm")
 private lazy var serviceRegistry = TranscriptionServiceRegistry(
 contextProvider: contextProvider,
 modelContext: modelContext,
 modelsDirectory: contextProvider.modelsDirectory
 )
 private let prewarmAudioURL = Bundle.main.url(forResource: "esc", withExtension: "wav")
 private let prewarmEnabledKey = UserDefaults.Keys.prewarmModelOnWake
 private var aiService: AIService?

 init(contextProvider: any WhisperContextProvider, modelContext: ModelContext, aiService: AIService? = nil) {
 self.contextProvider = contextProvider
 self.modelContext = modelContext
 self.aiService = aiService
 setupNotifications()
 schedulePrewarmOnAppLaunch()
 }

 // MARK: - Notification Setup

 private func setupNotifications() {
 let center = NSWorkspace.shared.notificationCenter

 // Trigger on wake from sleep
 center.addObserver(
 self,
 selector: #selector(schedulePrewarm),
 name: NSWorkspace.didWakeNotification,
 object: nil
 )

 logger.notice(" ModelPrewarmService initialized - listening for wake and app launch")
 }

 // MARK: - Trigger Handlers

 /// Trigger on app launch (cold start)
 private func schedulePrewarmOnAppLaunch() {
 logger.notice(" App launched, scheduling prewarm")
 Task {
 try? await Task.sleep(for: .seconds(3))
 await performPrewarm()
 }
 }

 /// Trigger on wake from sleep or screen unlock
 @objc private func schedulePrewarm() {
 logger.notice(" Mac activity detected (wake/unlock), scheduling prewarm")
 Task {
 try? await Task.sleep(for: .seconds(3))
 await performPrewarm()
 }
 }

 // MARK: - Core Prewarming Logic

 private func performPrewarm() async {
 // Transcription model prewarm
 if shouldPrewarm() {
 if let audioURL = prewarmAudioURL {
 if let currentModel = contextProvider.currentTranscriptionModel {
 logger.notice(" Prewarming \(currentModel.displayName, privacy: .public)")
 let startTime = Date()

 do {
 let _ = try await serviceRegistry.transcribe(audioURL: audioURL, model: currentModel)
 let duration = Date().timeIntervalSince(startTime)
 logger.notice(" Prewarm completed in \(String(format: "%.2f", duration), privacy: .public)s")
 } catch {
 logger.error(" Prewarm failed: \(error.localizedDescription, privacy: .public)")
 }
 } else {
 logger.notice(" No model selected, skipping prewarm")
 }
 } else {
 logger.error(" Prewarm audio file (esc.wav) not found")
 }
 }

 // Enhancement LLM prewarm
 if let aiService = aiService {
 await LLMPrewarmService.shared.prewarm(aiService: aiService)
 }
 }

 // MARK: - Validation

 private func shouldPrewarm() -> Bool {
 // Check if user has enabled prewarming
 let isEnabled = UserDefaults.standard.bool(forKey: prewarmEnabledKey)
 guard isEnabled else {
 logger.notice(" Prewarm disabled by user")
 return false
 }

 // Only prewarm local models (Parakeet and Whisper need ANE compilation)
 guard let model = contextProvider.currentTranscriptionModel else {
 return false
 }

 switch model.provider {
 case .local, .parakeet:
 return true
 default:
 logger.notice(" Skipping prewarm - cloud models don't need it")
 return false
 }
 }

 deinit {
 NSWorkspace.shared.notificationCenter.removeObserver(self)
 logger.notice(" ModelPrewarmService deinitialized")
 }
}
