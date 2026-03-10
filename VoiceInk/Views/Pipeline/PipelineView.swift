import SwiftUI
import SwiftData

struct PipelineView: View {
 @Binding var selectedView: ViewType?
 @State private var selectedStage: PipelineStage = .outputFilters

 @AppStorage(UserDefaults.Keys.removeFillerWords) private var removeFillerWords = true
 @AppStorage(UserDefaults.Keys.removeTagBlocks) private var removeTagBlocks = true
 @AppStorage(UserDefaults.Keys.removeBracketedContent) private var removeBracketedContent = true
 @AppStorage(UserDefaults.Keys.isTextFormattingEnabled) private var textFormattingEnabled = true
 @AppStorage(UserDefaults.Keys.isAIEnhancementEnabled) private var aiEnhancementEnabled = false

 @Environment(\.modelContext) private var modelContext

 private var previewResults: [PipelinePreviewEngine.StageResult] {
  let pairs = fetchReplacementPairs()
  return PipelinePreviewEngine.run(wordReplacementPairs: pairs)
 }

 var body: some View {
  VStack(spacing: 0) {
   HSplitView {
    // Left column: stage list
    ScrollView {
     VStack(spacing: 0) {
      ForEach(PipelineStage.allCases) { stage in
       Button {
        selectedStage = stage
       } label: {
        PipelineStageCard(
         stage: stage,
         isSelected: selectedStage == stage,
         isEnabled: isStageEnabled(stage)
        )
       }
       .buttonStyle(.plain)

       if stage != PipelineStage.allCases.last {
        Image(systemName: "chevron.down")
         .font(.system(size: 10))
         .foregroundColor(.secondary.opacity(0.5))
         .frame(height: 16)
       }
      }
     }
     .padding(12)
    }
    .frame(minWidth: 200, idealWidth: 220, maxWidth: 260)

    // Right column: detail for selected stage
    PipelineStageDetailView(
     stage: selectedStage,
     selectedView: $selectedView
    )
    .frame(minWidth: 400)
   }

   Divider()

   // Bottom: live preview
   PipelineLivePreview(results: previewResults)
    .padding(12)
  }
  .accessibilityIdentifier(AccessibilityID.Pipeline.view)
 }

 private func isStageEnabled(_ stage: PipelineStage) -> Bool {
  switch stage {
  case .recording, .speechToText, .pasteOutput:
   return true
  case .outputFilters:
   return removeFillerWords || removeTagBlocks || removeBracketedContent
  case .textFormatting:
   return textFormattingEnabled
  case .wordReplacement:
   return true // always active when replacements exist
  case .aiEnhancement:
   return aiEnhancementEnabled
  }
 }

 private func fetchReplacementPairs() -> [(originalText: String, replacementText: String)] {
  let descriptor = FetchDescriptor<WordReplacement>(
   predicate: #Predicate { $0.isEnabled }
  )
  let replacements = (try? modelContext.fetch(descriptor)) ?? []
  return replacements.map { (originalText: $0.originalText, replacementText: $0.replacementText) }
 }
}
