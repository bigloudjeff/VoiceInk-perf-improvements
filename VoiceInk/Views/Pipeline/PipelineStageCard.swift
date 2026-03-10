import SwiftUI

struct PipelineStageCard: View {
 let stage: PipelineStage
 let isSelected: Bool
 let isEnabled: Bool

 var body: some View {
  HStack(spacing: 10) {
   // Number circle
   ZStack {
    Circle()
     .fill(isSelected ? stage.color : stage.color.opacity(0.15))
     .frame(width: 28, height: 28)
    Text("\(stage.rawValue)")
     .font(.system(size: 13, weight: .bold, design: .rounded))
     .foregroundColor(isSelected ? .white : stage.color)
   }

   VStack(alignment: .leading, spacing: 2) {
    HStack(spacing: 6) {
     Image(systemName: stage.icon)
      .font(.system(size: 11))
      .foregroundColor(isSelected ? stage.color : .secondary)
     Text(stage.title)
      .font(.system(size: 13, weight: .medium))
      .foregroundColor(.primary)
    }
    Text(stage.description)
     .font(.system(size: 10))
     .foregroundColor(.secondary)
     .lineLimit(1)
   }

   Spacer()

   if stage.isToggleable {
    Text(isEnabled ? "ON" : "OFF")
     .font(.system(size: 9, weight: .bold, design: .rounded))
     .foregroundColor(isEnabled ? .green : .secondary)
     .padding(.horizontal, 6)
     .padding(.vertical, 2)
     .background(
      Capsule()
       .fill(isEnabled ? Color.green.opacity(0.15) : Color.secondary.opacity(0.1))
     )
   }
  }
  .padding(.horizontal, 10)
  .padding(.vertical, 8)
  .background(
   RoundedRectangle(cornerRadius: 10)
    .fill(isSelected
     ? Color.accentColor.opacity(0.08)
     : Color(NSColor.windowBackgroundColor).opacity(0.4))
  )
  .overlay(
   RoundedRectangle(cornerRadius: 10)
    .stroke(
     isSelected ? Color.accentColor.opacity(0.3) : Color.clear,
     lineWidth: 1
    )
  )
  .contentShape(Rectangle())
  .accessibilityIdentifier(AccessibilityID.Pipeline.stageCard(stage.title))
 }
}
