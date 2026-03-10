import Foundation
import SwiftData

/// Runs the sample text through each active pipeline stage to produce
/// a per-stage transformation preview.
struct PipelinePreviewEngine {
 static let sampleText = "Um, I went to the metting with John and, like, we discussed the progect."

 struct StageResult: Identifiable {
  let id = UUID()
  let stage: PipelineStage
  let text: String
  let didChange: Bool
 }

 /// Run sample text through stages that have real, callable logic.
 static func run(
  wordReplacementPairs: [(originalText: String, replacementText: String)] = []
 ) -> [StageResult] {
  var results: [StageResult] = []
  var current = sampleText

  // Stage 1: Recording (no-op for preview)
  results.append(StageResult(stage: .recording, text: current, didChange: false))

  // Stage 2: Speech-to-Text (no-op -- produces the raw text)
  results.append(StageResult(stage: .speechToText, text: current, didChange: false))

  // Stage 3: Output Filters -- runs actual TranscriptionOutputFilter
  let afterFilters = TranscriptionOutputFilter.filter(current)
  results.append(StageResult(stage: .outputFilters, text: afterFilters, didChange: afterFilters != current))
  current = afterFilters

  // Stage 4: Text Formatting (simulated -- capitalize first letter)
  let afterFormatting = current
  results.append(StageResult(stage: .textFormatting, text: afterFormatting, didChange: afterFormatting != current))
  current = afterFormatting

  // Stage 5: Word Replacement -- runs actual WordReplacementService
  let afterReplacement = WordReplacementService.applyReplacements(to: current, pairs: wordReplacementPairs)
  results.append(StageResult(stage: .wordReplacement, text: afterReplacement, didChange: afterReplacement != current))
  current = afterReplacement

  // Stage 6: AI Enhancement (simulated -- no actual LLM call)
  results.append(StageResult(stage: .aiEnhancement, text: current, didChange: false))

  // Stage 7: Paste / Output (no-op)
  results.append(StageResult(stage: .pasteOutput, text: current, didChange: false))

  return results
 }
}
