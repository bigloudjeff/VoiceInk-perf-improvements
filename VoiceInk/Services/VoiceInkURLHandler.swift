import Foundation
import SwiftData

@MainActor
enum VoiceInkURLHandler {
 static func handle(_ url: URL, container: ModelContainer) {
  guard url.scheme == "voiceink",
        let host = url.host else { return }

  switch host {
  case "vocabulary":
   handleVocabulary(url, container: container)
  default:
   break
  }
 }

 private static func handleVocabulary(_ url: URL, container: ModelContainer) {
  let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
  let params = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
  let word = params.first(where: { $0.name == "word" })?.value
  let hints = params.first(where: { $0.name == "hints" })?.value

  switch path {
  case "add":
   guard let word, !word.isEmpty else {
    NotificationManager.shared.showNotification(title: "Missing word parameter", type: .error)
    return
   }
   let result = CustomVocabularyService.shared.addWords(word, phoneticHints: hints, in: container)
   if !result.added.isEmpty {
    NotificationManager.shared.showNotification(
     title: "Added: \(result.added.joined(separator: ", "))",
     type: .success
    )
   } else if !result.duplicates.isEmpty {
    NotificationManager.shared.showNotification(
     title: "Already exists: \(result.duplicates.joined(separator: ", "))",
     type: .info
    )
   }

  case "remove":
   guard let word, !word.isEmpty else {
    NotificationManager.shared.showNotification(title: "Missing word parameter", type: .error)
    return
   }
   if CustomVocabularyService.shared.removeWord(word, from: container) {
    NotificationManager.shared.showNotification(title: "Removed: \(word)", type: .success)
   } else {
    NotificationManager.shared.showNotification(title: "Not found: \(word)", type: .info)
   }

  case "list":
   guard let menuBarManager = AppServiceLocator.shared.menuBarManager else { return }
   menuBarManager.focusMainWindow()
   NotificationCenter.default.post(
    name: .navigateToDestination,
    object: nil,
    userInfo: ["destination": "Dictionary"]
   )

  default:
   break
  }
 }
}
