import SwiftUI

enum PipelineStage: Int, CaseIterable, Identifiable {
 case recording = 1
 case speechToText
 case outputFilters
 case textFormatting
 case wordReplacement
 case aiEnhancement
 case pasteOutput

 var id: Int { rawValue }

 var title: String {
  switch self {
  case .recording: return "Recording"
  case .speechToText: return "Speech-to-Text"
  case .outputFilters: return "Output Filters"
  case .textFormatting: return "Text Formatting"
  case .wordReplacement: return "Word Replacement"
  case .aiEnhancement: return "AI Enhancement"
  case .pasteOutput: return "Paste / Output"
  }
 }

 var icon: String {
  switch self {
  case .recording: return "mic.fill"
  case .speechToText: return "waveform"
  case .outputFilters: return "line.3.horizontal.decrease"
  case .textFormatting: return "textformat"
  case .wordReplacement: return "arrow.left.arrow.right"
  case .aiEnhancement: return "wand.and.stars"
  case .pasteOutput: return "doc.on.clipboard"
  }
 }

 var description: String {
  switch self {
  case .recording: return "Capture audio from your microphone"
  case .speechToText: return "Convert speech to raw text"
  case .outputFilters: return "Remove filler words, tags, and artifacts"
  case .textFormatting: return "Capitalize and format the text"
  case .wordReplacement: return "Fix misspelled names and terms"
  case .aiEnhancement: return "Rewrite with AI for clarity and tone"
  case .pasteOutput: return "Deliver text to the active application"
  }
 }

 var color: Color {
  switch self {
  case .recording: return .red
  case .speechToText: return .blue
  case .outputFilters: return .orange
  case .textFormatting: return .purple
  case .wordReplacement: return .green
  case .aiEnhancement: return .indigo
  case .pasteOutput: return .teal
  }
 }

 /// Whether this stage can be toggled on/off by the user.
 var isToggleable: Bool {
  switch self {
  case .recording, .speechToText, .pasteOutput: return false
  case .outputFilters, .textFormatting, .wordReplacement, .aiEnhancement: return true
  }
 }
}
