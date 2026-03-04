import Foundation

struct SettingsSearchEntry: Identifiable {
 let id = UUID()
 let title: String
 let pane: ViewType
 let section: String
 let keywords: [String]

 func matches(_ query: String) -> Bool {
  let q = query.lowercased()
  if title.lowercased().contains(q) { return true }
  return keywords.contains { $0.lowercased().contains(q) }
 }
}
