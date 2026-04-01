import AVFoundation
import FluidAudio
import Foundation
import os

/// On-device streaming transcription provider using FluidAudio's Parakeet models.
/// Currently disabled -- FluidAudio 0.13.4 restructured the streaming API.
/// Re-enable when upstream stabilizes the Parakeet streaming interface.
final class ParakeetStreamingProvider: StreamingTranscriptionProvider {

 private let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "ParakeetStreaming")
 private var eventsContinuation: AsyncStream<StreamingTranscriptionEvent>.Continuation?

 private(set) var transcriptionEvents: AsyncStream<StreamingTranscriptionEvent>

 init(parakeetService: ParakeetTranscriptionService) {
  var continuation: AsyncStream<StreamingTranscriptionEvent>.Continuation!
  transcriptionEvents = AsyncStream { continuation = $0 }
  eventsContinuation = continuation
 }

 deinit {
  eventsContinuation?.finish()
 }

 func connect(model: any TranscriptionModel, language: String?) async throws {
  logger.error("Parakeet streaming not yet supported with FluidAudio 0.13.4")
  throw StreamingTranscriptionError.notConnected
 }

 func sendAudioChunk(_ data: Data) async throws {
  throw StreamingTranscriptionError.notConnected
 }

 func commit() async throws {
  throw StreamingTranscriptionError.notConnected
 }

 func disconnect() async {
  eventsContinuation?.finish()
 }
}
