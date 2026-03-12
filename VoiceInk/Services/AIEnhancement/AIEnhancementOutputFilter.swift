import Foundation

struct AIEnhancementOutputFilter {
 private static let strippableTagRegexes: [NSRegularExpression] = {
  [
   #"(?s)<thinking>(.*?)</thinking>"#,
   #"(?s)<think>(.*?)</think>"#,
   #"(?s)<reasoning>(.*?)</reasoning>"#,
   #"(?s)<SYSTEM_INSTRUCTIONS>(.*?)</SYSTEM_INSTRUCTIONS>"#,
   #"(?s)<TRANSCRIPT>(.*?)</TRANSCRIPT>"#,
  ].compactMap { try? NSRegularExpression(pattern: $0) }
 }()

 /// Phrases that indicate the model echoed the system prompt instead of
 /// returning cleaned transcription text.
 private static let systemPromptLeakPhrases = [
  "You are a transcription cleaner",
  "Your ONLY job is to lightly clean up",
  "Output ONLY the cleaned text. No explanations, labels, or tags.",
 ]

 static func filter(_ text: String) -> String {
  var processedText = text

  for regex in strippableTagRegexes {
   let range = NSRange(processedText.startIndex..., in: processedText)
   processedText = regex.stringByReplacingMatches(in: processedText, options: [], range: range, withTemplate: "")
  }

  processedText = processedText.trimmingCharacters(in: .whitespacesAndNewlines)

  // If the model echoed system prompt text without XML wrappers,
  // try to strip everything before the actual transcript content.
  if systemPromptLeakPhrases.contains(where: { processedText.contains($0) }) {
   // Look for the cleaned text after the leaked prompt block.
   // Common patterns: prompt ends with a blank line, then the real output follows.
   let lines = processedText.components(separatedBy: "\n")
   var lastPromptLine = -1
   for (i, line) in lines.enumerated() {
    if systemPromptLeakPhrases.contains(where: { line.contains($0) }) {
     lastPromptLine = i
    }
   }
   if lastPromptLine >= 0 && lastPromptLine < lines.count - 1 {
    let remaining = lines[(lastPromptLine + 1)...].joined(separator: "\n")
     .trimmingCharacters(in: .whitespacesAndNewlines)
    if !remaining.isEmpty {
     processedText = remaining
    }
   }
  }

  return processedText
 }
} 