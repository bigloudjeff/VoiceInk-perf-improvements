import Foundation
import AppKit
import Zip

struct TranscriptionEntryMetadata: Codable {
 let id: UUID
 let text: String
 let enhancedText: String?
 let timestamp: Date
 let duration: TimeInterval
 let transcriptionModelName: String?
 let aiEnhancementModelName: String?
 let promptName: String?
 let transcriptionDuration: TimeInterval?
 let enhancementDuration: TimeInterval?
 let aiRequestSystemMessage: String?
 let aiRequestUserMessage: String?
 let powerModeName: String?
 let powerModeEmoji: String?
 let transcriptionStatus: String?
 let isPinned: Bool
}

class TranscriptionEntryExportService {

 func exportEntry(_ transcription: Transcription) {
  // Capture all data from the SwiftData model on the main thread
  let metadata = TranscriptionEntryMetadata(
   id: transcription.id,
   text: transcription.text,
   enhancedText: transcription.enhancedText,
   timestamp: transcription.timestamp,
   duration: transcription.duration,
   transcriptionModelName: transcription.transcriptionModelName,
   aiEnhancementModelName: transcription.aiEnhancementModelName,
   promptName: transcription.promptName,
   transcriptionDuration: transcription.transcriptionDuration,
   enhancementDuration: transcription.enhancementDuration,
   aiRequestSystemMessage: transcription.aiRequestSystemMessage,
   aiRequestUserMessage: transcription.aiRequestUserMessage,
   powerModeName: transcription.powerModeName,
   powerModeEmoji: transcription.powerModeEmoji,
   transcriptionStatus: transcription.transcriptionStatus,
   isPinned: transcription.isPinned
  )
  let audioFileURL = transcription.audioFileURL
  let suggestedName = buildSuggestedFilename(transcription)

  // Do all file I/O on a background thread
  DispatchQueue.global(qos: .userInitiated).async {
   let tempDir = FileManager.default.temporaryDirectory
    .appendingPathComponent("VoiceInkExport-\(UUID().uuidString)")

   do {
    try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    let jsonData = try encoder.encode(metadata)
    try jsonData.write(to: tempDir.appendingPathComponent("metadata.json"))

    var pathsToZip = [tempDir.appendingPathComponent("metadata.json")]

    if let urlString = audioFileURL,
       let audioURL = URL(string: urlString),
       FileManager.default.fileExists(atPath: audioURL.path) {
     let destAudio = tempDir.appendingPathComponent("audio.wav")
     try FileManager.default.copyItem(at: audioURL, to: destAudio)
     pathsToZip.append(destAudio)
    }

    let zipPath = tempDir.appendingPathComponent("\(suggestedName).voiceink")
    try Zip.zipFiles(paths: pathsToZip, zipFilePath: zipPath, password: nil, progress: nil)

    // Present save panel on main thread
    DispatchQueue.main.async {
     self.presentSavePanel(suggestedName: suggestedName, sourceZip: zipPath, tempDir: tempDir)
    }
   } catch {
    DispatchQueue.main.async {
     self.showAlert(title: "Export Error", message: "Failed to export entry: \(error.localizedDescription)")
    }
    try? FileManager.default.removeItem(at: tempDir)
   }
  }
 }

 private func buildSuggestedFilename(_ transcription: Transcription) -> String {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd"
  let dateString = dateFormatter.string(from: transcription.timestamp)

  let displayText = transcription.enhancedText ?? transcription.text
  let words = displayText.split(separator: " ").prefix(4).joined(separator: "_")
  let safeWords = words
   .replacingOccurrences(of: "/", with: "-")
   .replacingOccurrences(of: ":", with: "-")
   .prefix(40)

  return "VoiceInk_\(dateString)_\(safeWords)"
 }

 private func presentSavePanel(suggestedName: String, sourceZip: URL, tempDir: URL) {
  let savePanel = NSSavePanel()
  savePanel.nameFieldStringValue = "\(suggestedName).voiceink"
  savePanel.title = "Export Transcription"
  savePanel.message = "Choose a location to save the transcription archive."

  if savePanel.runModal() == .OK, let destURL = savePanel.url {
   do {
    if FileManager.default.fileExists(atPath: destURL.path) {
     try FileManager.default.removeItem(at: destURL)
    }
    try FileManager.default.copyItem(at: sourceZip, to: destURL)
   } catch {
    self.showAlert(title: "Export Error", message: "Could not save file: \(error.localizedDescription)")
   }
  }

  // Cleanup temp dir after save panel closes
  DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 5) {
   try? FileManager.default.removeItem(at: tempDir)
  }
 }

 private func showAlert(title: String, message: String) {
  let alert = NSAlert()
  alert.messageText = title
  alert.informativeText = message
  alert.alertStyle = .warning
  alert.addButton(withTitle: "OK")
  alert.runModal()
 }
}
