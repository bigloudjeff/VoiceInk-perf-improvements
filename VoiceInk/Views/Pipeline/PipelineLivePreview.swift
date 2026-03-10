import SwiftUI

struct PipelineLivePreview: View {
 let results: [PipelinePreviewEngine.StageResult]

 private var changedResults: [PipelinePreviewEngine.StageResult] {
  results.filter { $0.didChange }
 }

 var body: some View {
  VStack(alignment: .leading, spacing: 6) {
   HStack(spacing: 6) {
    Image(systemName: "eye")
     .font(.system(size: 11))
     .foregroundColor(.secondary)
    Text("Live Preview")
     .font(.system(size: 11, weight: .semibold))
     .foregroundColor(.secondary)
   }

   // Original
   HStack(alignment: .top, spacing: 6) {
    Text("Input:")
     .font(.system(size: 10, weight: .medium))
     .foregroundColor(.secondary)
     .frame(width: 70, alignment: .trailing)
    Text(PipelinePreviewEngine.sampleText)
     .font(.system(size: 11, design: .monospaced))
     .foregroundColor(.primary.opacity(0.7))
     .lineLimit(2)
   }

   // Show each stage that changed something
   ForEach(changedResults) { result in
    HStack(alignment: .top, spacing: 6) {
     Text("After \(result.stage.title):")
      .font(.system(size: 10, weight: .medium))
      .foregroundColor(result.stage.color)
      .frame(width: 70, alignment: .trailing)
     Text(result.text)
      .font(.system(size: 11, design: .monospaced))
      .foregroundColor(.primary)
      .lineLimit(2)
    }
   }

   if changedResults.isEmpty {
    HStack(spacing: 6) {
     Spacer()
      .frame(width: 70)
     Text("No active filters modify the sample text.")
      .font(.system(size: 11))
      .foregroundColor(.secondary)
      .italic()
    }
   }

   // Final output
   if let last = results.last {
    HStack(alignment: .top, spacing: 6) {
     Text("Output:")
      .font(.system(size: 10, weight: .bold))
      .foregroundColor(.primary)
      .frame(width: 70, alignment: .trailing)
     Text(last.text)
      .font(.system(size: 11, weight: .medium, design: .monospaced))
      .foregroundColor(.primary)
      .lineLimit(2)
    }
   }
  }
  .padding(12)
  .background(
   RoundedRectangle(cornerRadius: 10)
    .fill(Color(NSColor.windowBackgroundColor).opacity(0.5))
  )
  .overlay(
   RoundedRectangle(cornerRadius: 10)
    .stroke(Color(NSColor.quaternaryLabelColor).opacity(0.3), lineWidth: 1)
  )
  .accessibilityIdentifier(AccessibilityID.Pipeline.livePreview)
 }
}
