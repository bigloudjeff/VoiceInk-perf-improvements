import Foundation
import SwiftUI

@Observable
class EnhancementShortcutSettings {
    static let shared = EnhancementShortcutSettings()

    var isToggleEnhancementShortcutEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isToggleEnhancementShortcutEnabled, forKey: UserDefaults.Keys.isToggleEnhancementShortcutEnabled)
            NotificationCenter.default.post(name: .enhancementShortcutSettingChanged, object: nil)
        }
    }

    private init() {
        self.isToggleEnhancementShortcutEnabled = UserDefaults.standard.bool(forKey: UserDefaults.Keys.isToggleEnhancementShortcutEnabled)
    }
}
