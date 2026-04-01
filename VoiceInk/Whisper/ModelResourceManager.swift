import Foundation

@MainActor
class ModelResourceManager {
 private let localModelManager: LocalModelManager
 private let serviceRegistry: TranscriptionServiceRegistry
 private var modelCleanupTimer: Task<Void, Never>?

 init(localModelManager: LocalModelManager, serviceRegistry: TranscriptionServiceRegistry) {
  self.localModelManager = localModelManager
  self.serviceRegistry = serviceRegistry
 }

 func scheduleModelCleanup() {
  modelCleanupTimer?.cancel()
  modelCleanupTimer = Task {
   try? await Task.sleep(for: .seconds(60))
   guard !Task.isCancelled else { return }
   await self.cleanupModelResources()
  }
 }

 func cancelScheduledModelCleanup() {
  modelCleanupTimer?.cancel()
  modelCleanupTimer = nil
 }

 func cleanupModelResources() async {
  await localModelManager.cleanupModelResources()
  await serviceRegistry.cleanup()
 }
}
