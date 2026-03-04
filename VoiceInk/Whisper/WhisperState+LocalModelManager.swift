import Foundation
import SwiftUI

struct WhisperModel: Identifiable {
 let id = UUID()
 let name: String
 let url: URL
 var coreMLEncoderURL: URL?
 var isCoreMLDownloaded: Bool { coreMLEncoderURL != nil }

 var downloadURL: String {
  "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/\(filename)"
 }

 var filename: String {
  "\(name).bin"
 }

 var coreMLZipDownloadURL: String? {
  guard !name.contains("q5") && !name.contains("q8") else { return nil }
  return "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/\(name)-encoder.mlmodelc.zip"
 }

 var coreMLEncoderDirectoryName: String? {
  guard coreMLZipDownloadURL != nil else { return nil }
  return "\(name)-encoder.mlmodelc"
 }
}

// MARK: - WhisperState Thin Wrappers (delegate to LocalModelManager)

extension WhisperState {

 func loadModel(_ model: WhisperModel) async throws {
  try await localModelManager.loadModel(model)
 }

 func downloadModel(_ model: LocalModel) async {
  await localModelManager.downloadModel(model)
 }

 func deleteModel(_ model: WhisperModel) async {
  await localModelManager.deleteModel(model, currentTranscriptionModelName: currentTranscriptionModel?.name)
  refreshAllAvailableModels()
 }

 func unloadModel() {
  localModelManager.unloadModel()
  self.recordedFile = nil
 }

 func clearDownloadedModels() async {
  await localModelManager.clearDownloadedModels()
 }

 func cleanupModelResources() async {
  await modelResourceManager.cleanupModelResources()
 }

 func importLocalModel(from sourceURL: URL) async {
  await localModelManager.importLocalModel(from: sourceURL)
 }
}

// MARK: - LocalModelManagerDelegate

extension WhisperState: LocalModelManagerDelegate {

 func localModelManagerDidUpdateAvailableModels(_ models: [WhisperModel]) {
  self.availableModels = models
 }

 func localModelManagerDidUpdateDownloadProgress(_ progress: [String: Double]) {
  self.downloadProgress = progress
 }

 func localModelManagerDidUpdateModelLoaded(_ loaded: Bool) {
  self.isModelLoaded = loaded
 }

 func localModelManagerDidUpdateModelLoading(_ loading: Bool) {
  self.isModelLoading = loading
 }

 func localModelManagerDidUpdateWhisperContext(_ context: WhisperContext?) {
  self.whisperContext = context
 }

 func localModelManagerDidUpdateLoadedLocalModel(_ model: WhisperModel?) {
  self.loadedLocalModel = model
 }

 func localModelManagerDidDeleteCurrentModel(named: String) {
  currentTranscriptionModel = nil
  UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.currentTranscriptionModel)
  recordingState = .idle
  UserDefaults.standard.removeObject(forKey: "CurrentModel")
 }

 func localModelManagerDidImportModel(name: String, asTranscriptionModel model: ImportedLocalModel) {
  if !allAvailableModels.contains(where: { $0.name == name }) {
   allAvailableModels.append(model)
  }
 }
}

// MARK: - Download Progress View

struct DownloadProgressView: View {
 let modelName: String
 let downloadProgress: [String: Double]

 @Environment(\.colorScheme) private var colorScheme

 private var mainProgress: Double {
  downloadProgress[modelName + "_main"] ?? 0
 }

 private var coreMLProgress: Double {
  supportsCoreML ? (downloadProgress[modelName + "_coreml"] ?? 0) : 0
 }

 private var supportsCoreML: Bool {
  !modelName.contains("q5") && !modelName.contains("q8")
 }

 private var totalProgress: Double {
  supportsCoreML ? (mainProgress * 0.5) + (coreMLProgress * 0.5) : mainProgress
 }

 private var downloadPhase: String {
  if supportsCoreML && downloadProgress[modelName + "_coreml"] != nil {
   return "Downloading Core ML Model for \(modelName)"
  }
  return "Downloading \(modelName) Model"
 }

 var body: some View {
  VStack(alignment: .leading, spacing: 8) {
   Text(downloadPhase)
    .font(.system(size: 12, weight: .medium))
    .foregroundColor(Color(.secondaryLabelColor))

   GeometryReader { geometry in
    ZStack(alignment: .leading) {
     RoundedRectangle(cornerRadius: 4)
      .fill(Color(.separatorColor).opacity(0.3))
      .frame(height: 6)

     RoundedRectangle(cornerRadius: 4)
      .fill(Color(.controlAccentColor))
      .frame(width: max(0, min(geometry.size.width * totalProgress, geometry.size.width)), height: 6)
    }
   }
   .frame(height: 6)

   HStack {
    Spacer()
    Text("\(Int(totalProgress * 100))%")
     .font(.system(size: 11, weight: .medium, design: .monospaced))
     .foregroundColor(Color(.secondaryLabelColor))
   }
  }
  .padding(.vertical, 4)
  .animation(.smooth, value: totalProgress)
 }
}
