import SwiftUI
import SwiftData

struct DictionarySettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedSection: DictionarySection = .replacements
    let whisperPrompt: WhisperPrompt
    
    enum DictionarySection: String, CaseIterable {
        case replacements = "Word Replacements"
        case spellings = "Vocabulary"
        case suggestions = "Suggestions"

        var description: String {
            switch self {
            case .spellings:
                return "Add words to help VoiceInk recognize them properly"
            case .replacements:
                return "Automatically replace specific words/phrases with custom formatted text "
            case .suggestions:
                return "Review vocabulary corrections detected from AI enhancement"
            }
        }

        var icon: String {
            switch self {
            case .spellings:
                return "character.book.closed.fill"
            case .replacements:
                return "arrow.2.squarepath"
            case .suggestions:
                return "lightbulb.fill"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                sectionSelector
                selectedSectionContent
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var sectionSelector: some View {
        HStack(spacing: 8) {
            ForEach(DictionarySection.allCases, id: \.self) { section in
                Button {
                    selectedSection = section
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: section.icon)
                            .font(.system(size: 11))
                        Text(section.rawValue)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(selectedSection == section ? Color.accentColor.opacity(0.15) : Color.clear)
                    .foregroundColor(selectedSection == section ? .accentColor : .secondary)
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .help(section.description)
            }

            Spacer()

            Button(action: {
                DictionaryImportExportService.shared.importDictionary(into: modelContext)
            }) {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AccessibilityID.Dictionary.buttonImport)
            .help("Import vocabulary and word replacements")

            Button(action: {
                DictionaryImportExportService.shared.exportDictionary(from: modelContext)
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(AccessibilityID.Dictionary.buttonExport)
            .help("Export vocabulary and word replacements")
        }
    }
    
    private var selectedSectionContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            switch selectedSection {
            case .spellings:
                VocabularyView(whisperPrompt: whisperPrompt)
                    .background(CardBackground(isSelected: false))
            case .replacements:
                WordReplacementView()
                    .background(CardBackground(isSelected: false))
            case .suggestions:
                VocabularySuggestionsView()
                    .background(CardBackground(isSelected: false))
            }
        }
    }
}

struct SectionCard: View {
    let section: DictionarySettingsView.DictionarySection
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: section.icon)
                    .font(.system(size: 28))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isSelected ? .blue : .secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.rawValue)
                        .font(.headline)
                    
                    Text(section.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(CardBackground(isSelected: isSelected))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("dictionary.tab.\(section.rawValue)")
    }
}
