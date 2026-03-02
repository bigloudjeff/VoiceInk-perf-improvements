import Foundation
import os

class CommonWordsService {
 static let shared = CommonWordsService()

 private let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "CommonWords")
 private var cache: [String: Set<String>] = [:]
 private let lock = NSLock()

 private init() {}

 func commonWords(for languageCode: String) -> Set<String> {
  lock.lock()
  if let cached = cache[languageCode] {
   lock.unlock()
   return cached
  }
  lock.unlock()

  guard let url = Bundle.main.url(forResource: languageCode, withExtension: "txt") else {
   logger.info("No common words file for language: \(languageCode, privacy: .public)")
   lock.lock()
   cache[languageCode] = []
   lock.unlock()
   return []
  }

  do {
   let contents = try String(contentsOf: url, encoding: .utf8)
   let words = Set(
    contents
     .components(separatedBy: .newlines)
     .map {
      $0.trimmingCharacters(in: .whitespaces)
       .lowercased()
       .folding(options: .diacriticInsensitive, locale: nil)
     }
     .filter { !$0.isEmpty }
   )
   lock.lock()
   cache[languageCode] = words
   lock.unlock()
   logger.info("Loaded \(words.count, privacy: .public) common words for language: \(languageCode, privacy: .public)")
   return words
  } catch {
   logger.error("Failed to load common words for \(languageCode, privacy: .public): \(error.localizedDescription, privacy: .public)")
   lock.lock()
   cache[languageCode] = []
   lock.unlock()
   return []
  }
 }
}
