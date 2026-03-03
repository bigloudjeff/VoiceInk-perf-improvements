import Foundation
import FluidAudio
import AppKit

@MainActor
protocol ParakeetModelManagerDelegate: AnyObject {
 func parakeetManagerDidUpdateDownloadStates(_ states: [String: Bool])
 func parakeetManagerSetDownloadProgress(key: String, value: Double)
 func parakeetManagerRemoveDownloadProgress(key: String)
 func parakeetManagerIncrementProgress(key: String, increment: Double, cap: Double)
 func parakeetManagerDidDeleteCurrentModel(named: String)
 func parakeetManagerRequestRefreshAllModels()
}

@MainActor
class ParakeetModelManager {

 weak var delegate: ParakeetModelManagerDelegate?

 private(set) var downloadStates: [String: Bool] = [:] {
  didSet { delegate?.parakeetManagerDidUpdateDownloadStates(downloadStates) }
 }

 // MARK: - Status Queries

 func isModelDownloaded(named modelName: String) -> Bool {
  UserDefaults.standard.bool(forKey: defaultsKey(for: modelName))
 }

 func isModelDownloaded(_ model: ParakeetModel) -> Bool {
  isModelDownloaded(named: model.name)
 }

 func isModelDownloading(_ model: ParakeetModel) -> Bool {
  downloadStates[model.name] ?? false
 }

 // MARK: - Download

 func downloadModel(_ model: ParakeetModel) async {
  if isModelDownloaded(model) { return }

  let modelName = model.name
  downloadStates[modelName] = true
  delegate?.parakeetManagerSetDownloadProgress(key: modelName, value: 0.0)

  let timer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { timer in
   Task { @MainActor [weak self] in
    guard let self else { return }
    self.delegate?.parakeetManagerIncrementProgress(key: modelName, increment: 0.005, cap: 0.9)
   }
  }

  let version = parakeetVersion(for: modelName)

  do {
   _ = try await AsrModels.downloadAndLoad(version: version)
   _ = try await VadManager()
   UserDefaults.standard.set(true, forKey: defaultsKey(for: modelName))
   delegate?.parakeetManagerSetDownloadProgress(key: modelName, value: 1.0)
  } catch {
   UserDefaults.standard.set(false, forKey: defaultsKey(for: modelName))
  }

  timer.invalidate()
  downloadStates[modelName] = false
  delegate?.parakeetManagerRemoveDownloadProgress(key: modelName)
  delegate?.parakeetManagerRequestRefreshAllModels()
 }

 // MARK: - Delete

 func deleteModel(_ model: ParakeetModel, currentTranscriptionModelName: String?) {
  if let currentName = currentTranscriptionModelName, currentName == model.name {
   delegate?.parakeetManagerDidDeleteCurrentModel(named: model.name)
  }

  let version = parakeetVersion(for: model.name)
  let cacheDirectory = parakeetCacheDirectory(for: version)

  do {
   if FileManager.default.fileExists(atPath: cacheDirectory.path) {
    try FileManager.default.removeItem(at: cacheDirectory)
   }
   UserDefaults.standard.set(false, forKey: defaultsKey(for: model.name))
  } catch {
   // Silently ignore removal errors
  }

  delegate?.parakeetManagerRequestRefreshAllModels()
 }

 // MARK: - Show in Finder

 func showModelInFinder(_ model: ParakeetModel) {
  let cacheDirectory = parakeetCacheDirectory(for: parakeetVersion(for: model.name))
  if FileManager.default.fileExists(atPath: cacheDirectory.path) {
   NSWorkspace.shared.selectFile(cacheDirectory.path, inFileViewerRootedAtPath: "")
  }
 }

 // MARK: - Private Helpers

 private func defaultsKey(for modelName: String) -> String {
  "ParakeetModelDownloaded_\(modelName)"
 }

 private func parakeetVersion(for modelName: String) -> AsrModelVersion {
  modelName.lowercased().contains("v2") ? .v2 : .v3
 }

 private func parakeetCacheDirectory(for version: AsrModelVersion) -> URL {
  AsrModels.defaultCacheDirectory(for: version)
 }
}
