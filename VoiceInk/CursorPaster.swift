import Foundation
import AppKit
import os

private let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "CursorPaster")

class CursorPaster {

    // MARK: - Cached preferences

    private static var shouldRestoreClipboard = UserDefaults.standard.bool(forKey: UserDefaults.Keys.restoreClipboardAfterPaste)
    private static var shouldUseAppleScript = UserDefaults.standard.bool(forKey: UserDefaults.Keys.useAppleScriptPaste)
    private static var restoreDelay = UserDefaults.standard.double(forKey: UserDefaults.Keys.clipboardRestoreDelay)
    static var appendTrailingSpace = UserDefaults.standard.bool(forKey: UserDefaults.Keys.appendTrailingSpace)
    private static var pasteMethod = UserDefaults.standard.string(forKey: UserDefaults.Keys.pasteMethod) ?? "default"

    private static let prefsObserver: NSObjectProtocol = {
        NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: nil, queue: .main
        ) { _ in
            shouldRestoreClipboard = UserDefaults.standard.bool(forKey: UserDefaults.Keys.restoreClipboardAfterPaste)
            shouldUseAppleScript = UserDefaults.standard.bool(forKey: UserDefaults.Keys.useAppleScriptPaste)
            restoreDelay = UserDefaults.standard.double(forKey: UserDefaults.Keys.clipboardRestoreDelay)
            appendTrailingSpace = UserDefaults.standard.bool(forKey: UserDefaults.Keys.appendTrailingSpace)
            pasteMethod = UserDefaults.standard.string(forKey: UserDefaults.Keys.pasteMethod) ?? "default"
        }
    }()

    static func setupObservers() {
        _ = prefsObserver
    }

    static func pasteAtCursor(_ text: String) {
        _ = prefsObserver

        // Type-out bypasses the clipboard entirely
        let effectiveMethod = resolvedPasteMethod
        if effectiveMethod == "typeOut" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                typeText(text)
            }
            return
        }

        let pasteboard = NSPasteboard.general

        var savedContents: [(NSPasteboard.PasteboardType, Data)] = []

        if shouldRestoreClipboard {
            let currentItems = pasteboard.pasteboardItems ?? []

            for item in currentItems {
                for type in item.types {
                    if let data = item.data(forType: type) {
                        savedContents.append((type, data))
                    }
                }
            }
        }

        ClipboardManager.setClipboard(text, transient: shouldRestoreClipboard)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if effectiveMethod == "appleScript" {
                pasteUsingAppleScript()
            } else {
                pasteFromClipboard()
            }

            // Restore clipboard relative to paste time, not call time
            if shouldRestoreClipboard && !savedContents.isEmpty {
                let delay = max(restoreDelay, 0.1)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    pasteboard.clearContents()
                    for (type, data) in savedContents {
                        pasteboard.setData(data, forType: type)
                    }
                }
            }
        }
    }

    // Resolve paste method from both old toggle and new picker
    private static var resolvedPasteMethod: String {
        if pasteMethod != "default" {
            return pasteMethod
        }
        // Backwards compatibility: honor the old AppleScript toggle
        return shouldUseAppleScript ? "appleScript" : "default"
    }

    // MARK: - AppleScript paste

    // Pre-compiled once on first use to avoid per-paste overhead.
    private static let pasteScript: NSAppleScript? = {
        let script = NSAppleScript(source: """
            tell application "System Events"
                keystroke "v" using command down
            end tell
            """)
        var error: NSDictionary?
        script?.compileAndReturnError(&error)
        return script
    }()

    // Paste via AppleScript. Works with custom keyboard layouts (e.g. Neo2) where CGEvent-based paste fails.
    private static func pasteUsingAppleScript() {
        var error: NSDictionary?
        pasteScript?.executeAndReturnError(&error)
        if let error = error {
            logger.error("AppleScript paste failed: \(error, privacy: .public)")
        }
    }

    // MARK: - CGEvent paste

    // Posts Cmd+V via CGEvent without modifying the active input source.
    private static func pasteFromClipboard() {
        guard AXIsProcessTrusted() else {
            logger.error("Accessibility not trusted — cannot paste")
            return
        }

        let source = CGEventSource(stateID: .privateState)

        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true)
        let vDown   = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        let vUp     = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        let cmdUp   = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)

        cmdDown?.flags = .maskCommand
        vDown?.flags   = .maskCommand
        vUp?.flags     = .maskCommand

        cmdDown?.post(tap: .cghidEventTap)
        vDown?.post(tap: .cghidEventTap)
        vUp?.post(tap: .cghidEventTap)
        cmdUp?.post(tap: .cghidEventTap)

        logger.notice("CGEvents posted for Cmd+V")
    }

    // MARK: - Type out text

    // Type text character by character using CGEvents.
    // Bypasses the clipboard, useful for fields that block paste.
    static func typeText(_ text: String) {
        guard AXIsProcessTrusted() else {
            logger.error("Accessibility not trusted — cannot type")
            return
        }

        let source = CGEventSource(stateID: .privateState)
        let chars = Array(text.utf16)
        // Type in chunks to balance speed and reliability
        let chunkSize = 20
        let delayBetweenChunks: TimeInterval = 0.01

        for chunkStart in stride(from: 0, to: chars.count, by: chunkSize) {
            let chunkEnd = min(chunkStart + chunkSize, chars.count)
            let chunk = Array(chars[chunkStart..<chunkEnd])

            let delay = Double(chunkStart / chunkSize) * delayBetweenChunks
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                for char in chunk {
                    var utf16Char = char
                    let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)
                    let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false)
                    keyDown?.keyboardSetUnicodeString(stringLength: 1, unicodeString: &utf16Char)
                    keyUp?.keyboardSetUnicodeString(stringLength: 1, unicodeString: &utf16Char)
                    keyDown?.post(tap: .cghidEventTap)
                    keyUp?.post(tap: .cghidEventTap)
                }
            }
        }
    }

    // MARK: - Auto Send Keys

    static func performAutoSend(_ key: AutoSendKey) {
        guard key.isEnabled else { return }
        guard AXIsProcessTrusted() else { return }

        let source = CGEventSource(stateID: .privateState)
        let enterDown = CGEvent(keyboardEventSource: source, virtualKey: 0x24, keyDown: true)
        let enterUp   = CGEvent(keyboardEventSource: source, virtualKey: 0x24, keyDown: false)

        switch key {
        case .none: return
        case .enter: break
        case .shiftEnter:
            enterDown?.flags = .maskShift
            enterUp?.flags   = .maskShift
        case .commandEnter:
            enterDown?.flags = .maskCommand
            enterUp?.flags   = .maskCommand
        }

        enterDown?.post(tap: .cghidEventTap)
        enterUp?.post(tap: .cghidEventTap)
    }
}
