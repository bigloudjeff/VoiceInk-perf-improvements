import SwiftUI

struct SettingsSearchResultsView: View {
 let query: String
 @Binding var selectedView: ViewType?
 @Binding var searchText: String

 private var results: [SettingsSearchEntry] {
  SettingsSearchIndex.search(query)
 }

 var body: some View {
  if results.isEmpty {
   Text("No results for \"\(query)\"")
    .foregroundColor(.secondary)
    .font(.system(size: 13))
    .frame(maxWidth: .infinity, alignment: .center)
    .padding(.top, 20)
  } else {
   ForEach(results) { entry in
    Button {
     selectedView = entry.pane
     searchText = ""
    } label: {
     HStack(spacing: 10) {
      Image(systemName: entry.pane.icon)
       .font(.system(size: 14))
       .foregroundColor(.secondary)
       .frame(width: 20)
      VStack(alignment: .leading, spacing: 2) {
       Text(entry.title)
        .font(.system(size: 13, weight: .medium))
        .foregroundColor(.primary)
       Text("\(entry.section) -- \(entry.pane.rawValue)")
        .font(.system(size: 11))
        .foregroundColor(.secondary)
      }
      Spacer()
     }
     .padding(.vertical, 6)
     .padding(.horizontal, 8)
     .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
   }
  }
 }
}
