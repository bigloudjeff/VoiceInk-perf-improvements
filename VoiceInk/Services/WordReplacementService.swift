import Foundation
import SwiftData
import os

class WordReplacementService: WordReplacing {
    static let shared = WordReplacementService()
    private let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "WordReplacementService")

    private var cachedRegexes: [String: NSRegularExpression] = [:]

    private init() {}

    func invalidateCache() {
        cachedRegexes.removeAll()
    }

    func applyReplacements(to text: String, using context: ModelContext) -> String {
        let descriptor = FetchDescriptor<WordReplacement>(
            predicate: #Predicate { $0.isEnabled }
        )

        let replacements = context.safeFetch(descriptor, context: "word replacements", logger: logger)
        guard !replacements.isEmpty else {
            return text
        }

        var modifiedText = text

        for replacement in replacements {
            let variants = replacement.originalText
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }

            for original in variants {
                if Self.usesWordBoundaries(for: original) {
                    if let regex = cachedRegex(for: original) {
                        let range = NSRange(modifiedText.startIndex..., in: modifiedText)
                        modifiedText = regex.stringByReplacingMatches(
                            in: modifiedText,
                            options: [],
                            range: range,
                            withTemplate: replacement.replacementText
                        )
                    }
                } else {
                    modifiedText = modifiedText.replacingOccurrences(of: original, with: replacement.replacementText, options: .caseInsensitive)
                }
            }
        }

        return modifiedText
    }

    /// Pure transformation: apply replacement pairs to text without SwiftData dependency.
    /// Each pair's `originalText` may be comma-separated for multiple variants.
    /// Thread-safe static method suitable for testing.
    static func applyReplacements(to text: String, pairs: [(originalText: String, replacementText: String)]) -> String {
        guard !pairs.isEmpty else { return text }

        var modifiedText = text

        for pair in pairs {
            let variants = pair.originalText
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }

            for original in variants {
                if usesWordBoundaries(for: original) {
                    let pattern = "\\b\(NSRegularExpression.escapedPattern(for: original))\\b"
                    if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                        let range = NSRange(modifiedText.startIndex..., in: modifiedText)
                        modifiedText = regex.stringByReplacingMatches(
                            in: modifiedText,
                            options: [],
                            range: range,
                            withTemplate: pair.replacementText
                        )
                    }
                } else {
                    modifiedText = modifiedText.replacingOccurrences(of: original, with: pair.replacementText, options: .caseInsensitive)
                }
            }
        }

        return modifiedText
    }

    private func cachedRegex(for original: String) -> NSRegularExpression? {
        if let cached = cachedRegexes[original] {
            return cached
        }
        let pattern = "\\b\(NSRegularExpression.escapedPattern(for: original))\\b"
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        if let regex {
            cachedRegexes[original] = regex
        }
        return regex
    }

    private static func usesWordBoundaries(for text: String) -> Bool {
        // Returns false for languages without spaces (CJK, Thai), true for spaced languages
        let nonSpacedScripts: [ClosedRange<UInt32>] = [
            0x3040...0x309F, // Hiragana
            0x30A0...0x30FF, // Katakana
            0x4E00...0x9FFF, // CJK Unified Ideographs
            0xAC00...0xD7AF, // Hangul Syllables
            0x0E00...0x0E7F, // Thai
        ]

        for scalar in text.unicodeScalars {
            for range in nonSpacedScripts {
                if range.contains(scalar.value) {
                    return false
                }
            }
        }

        return true
    }
}
