import Foundation

// MARK: - WhisperState Parakeet Wrappers (delegate to ParakeetModelManager)

extension WhisperState {

 func isParakeetModelDownloaded(named modelName: String) -> Bool {
  parakeetModelManager.isModelDownloaded(named: modelName)
 }

 func isParakeetModelDownloaded(_ model: ParakeetModel) -> Bool {
  parakeetModelManager.isModelDownloaded(model)
 }

 func isParakeetModelDownloading(_ model: ParakeetModel) -> Bool {
  parakeetModelManager.isModelDownloading(model)
 }

 func downloadParakeetModel(_ model: ParakeetModel) async {
  await parakeetModelManager.downloadModel(model)
 }

 func deleteParakeetModel(_ model: ParakeetModel) {
  parakeetModelManager.deleteModel(model, currentTranscriptionModelName: currentTranscriptionModel?.name)
 }

 func showParakeetModelInFinder(_ model: ParakeetModel) {
  parakeetModelManager.showModelInFinder(model)
 }
}

// MARK: - ParakeetModelManagerDelegate

extension WhisperState: ParakeetModelManagerDelegate {

 func parakeetManagerDidUpdateDownloadStates(_ states: [String: Bool]) {
  // Download states tracked internally by ParakeetModelManager
 }

 func parakeetManagerSetDownloadProgress(key: String, value: Double) {
  modelDownloadProgress[key] = value
 }

 func parakeetManagerRemoveDownloadProgress(key: String) {
  modelDownloadProgress.removeValue(forKey: key)
 }

 func parakeetManagerIncrementProgress(key: String, increment: Double, cap: Double) {
  let current = modelDownloadProgress[key]
  if current > 0 && current < cap {
   modelDownloadProgress[key] = current + increment
  }
 }

 func parakeetManagerDidDeleteCurrentModel(named: String) {
  currentTranscriptionModel = nil
  UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.currentTranscriptionModel)
 }

 func parakeetManagerRequestRefreshAllModels() {
  refreshAllAvailableModels()
 }
}
