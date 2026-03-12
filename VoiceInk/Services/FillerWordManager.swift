import Foundation

class FillerWordManager: ObservableObject, FillerWordProviding {
    static let shared = FillerWordManager()

    static let defaultFillerWords = [
        "uh", "um", "uhm", "umm", "uhh", "uhhh", "ah", "eh",
        "hmm", "hm", "mmm", "mm", "mh", "ha", "ehh"
    ]

    private let fillerWordsKey = UserDefaults.Keys.fillerWords
    private let removeFillerWordsKey = UserDefaults.Keys.removeFillerWords

    @Published var fillerWords: [String] {
        didSet {
            UserDefaults.standard.set(fillerWords, forKey: fillerWordsKey)
            TranscriptionOutputFilter.invalidateFillerWordCache()
        }
    }

    var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: removeFillerWordsKey)
    }

    private init() {
        if let saved = UserDefaults.standard.stringArray(forKey: fillerWordsKey) {
            self.fillerWords = saved
        } else {
            self.fillerWords = Self.defaultFillerWords
        }
    }

    func addWord(_ word: String) -> Bool {
        let normalized = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else { return false }
        guard !fillerWords.contains(where: { $0.lowercased() == normalized }) else { return false }
        fillerWords.append(normalized)
        return true
    }

    func removeWord(_ word: String) {
        fillerWords.removeAll { $0.lowercased() == word.lowercased() }
    }

}
