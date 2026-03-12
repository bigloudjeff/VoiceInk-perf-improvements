import SwiftUI
import SwiftData

struct PipelineView: View {
 @Binding var selectedView: ViewType?
 @Binding var selectedStage: PipelineStage?

 @AppStorage(UserDefaults.Keys.removeFillerWords) private var removeFillerWords = true
 @AppStorage(UserDefaults.Keys.removeTagBlocks) private var removeTagBlocks = true
 @AppStorage(UserDefaults.Keys.removeBracketedContent) private var removeBracketedContent = true
 @AppStorage(UserDefaults.Keys.isTextFormattingEnabled) private var textFormattingEnabled = true
 @AppStorage(UserDefaults.Keys.isAIEnhancementEnabled) private var aiEnhancementEnabled = false

 @Environment(\.modelContext) private var modelContext

 private var currentStage: PipelineStage {
  selectedStage ?? .recording
 }

 private var previewResults: [PipelinePreviewEngine.StageResult] {
  let pairs = fetchReplacementPairs()
  return PipelinePreviewEngine.run(wordReplacementPairs: pairs)
 }

 var body: some View {
  VStack(spacing: 0) {
   // Stage detail content (full width)
   PipelineStageDetailView(
    stage: currentStage,
    selectedView: $selectedView
   )

   Divider()

   // Bottom: live preview
   PipelineLivePreview(results: previewResults)
    .padding(12)
  }
  .accessibilityIdentifier(AccessibilityID.Pipeline.view)
  .onAppear {
   if selectedStage == nil {
    selectedStage = .recording
   }
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
