import SwiftUI

struct PipelineLivePreview: View {
 let results: [PipelinePreviewEngine.StageResult]

 private var changedResults: [PipelinePreviewEngine.StageResult] {
  results.filter { $0.didChange }
 }

 var body: some View {
  VStack(alignment: .leading, spacing: 4) {
   HStack(spacing: 6) {
    Image(systemName: "eye")
     .font(.system(size: 11))
     .foregroundColor(.secondary)
    Text("Live Preview")
     .font(.system(size: 11, weight: .semibold))
     .foregroundColor(.secondary)
   }

   Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 6, verticalSpacing: 4) {
    GridRow {
     Text("Input:")
      .font(.system(size: 10, weight: .medium))
      .foregroundColor(.secondary)
      .gridColumnAlignment(.trailing)
     Text(PipelinePreviewEngine.sampleText)
      .font(.system(size: 11, design: .monospaced))
      .foregroundColor(.primary.opacity(0.7))
    }

    ForEach(changedResults) { result in
     GridRow {
      Text("\(result.stage.title):")
       .font(.system(size: 10, weight: .medium))
       .foregroundColor(result.stage.color)
      Text(result.text)
       .font(.system(size: 11, design: .monospaced))
       .foregroundColor(.primary)
     }
    }

    if changedResults.isEmpty {
     GridRow {
      Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
      Text("No active filters modify the sample text.")
       .font(.system(size: 11))
       .foregroundColor(.secondary)
       .italic()
     }
    }

    if let last = results.last {
     GridRow {
      Text("Output:")
       .font(.system(size: 10, weight: .bold))
       .foregroundColor(.primary)
      Text(last.text)
       .font(.system(size: 11, weight: .medium, design: .monospaced))
       .foregroundColor(.primary)
     }
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
