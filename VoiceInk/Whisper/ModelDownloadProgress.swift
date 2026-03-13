import Foundation
import Observation

@MainActor
@Observable
class ModelDownloadProgress {
 var downloadProgress: [String: Double] = [:]

 subscript(key: String) -> Double {
  get { downloadProgress[key] ?? 0 }
  set { downloadProgress[key] = newValue }
 }

 func removeValue(forKey key: String) {
  downloadProgress.removeValue(forKey: key)
 }
}
