import Foundation
import IOKit

/// Utility to obfuscate data stored in UserDefaults using XOR with a device-specific key.
/// Not cryptographically secure — intended to deter casual UserDefaults editing only.
struct Obfuscator {

    /// Encodes a string by XOR-ing with a salt-derived key, then Base64 encoding.
    static func encode(_ string: String, salt: String) -> String {
        let input = Array(string.utf8)
        let key = Array(salt.utf8)
        guard !key.isEmpty else { return Data(input).base64EncodedString() }
        var output = [UInt8](repeating: 0, count: input.count)
        for i in input.indices {
            output[i] = input[i] ^ key[i % key.count]
        }
        return Data(output).base64EncodedString()
    }

    /// Decodes a Base64+XOR string using the same salt.
    static func decode(_ base64: String, salt: String) -> String? {
        guard let data = Data(base64Encoded: base64) else { return nil }
        let input = Array(data)
        let key = Array(salt.utf8)
        guard !key.isEmpty else { return String(bytes: input, encoding: .utf8) }
        var output = [UInt8](repeating: 0, count: input.count)
        for i in input.indices {
            output[i] = input[i] ^ key[i % key.count]
        }
        return String(bytes: output, encoding: .utf8)
    }
    
    /// Gets a device-specific identifier to use as salt
    /// Uses the same logic as PolarService for consistency
    static func getDeviceIdentifier() -> String {
        // Try to get Mac serial number first
        if let serialNumber = getMacSerialNumber() {
            return serialNumber
        }
        
        // Fallback to stored UUID
        let defaults = UserDefaults.standard
        if let storedId = defaults.string(forKey: UserDefaults.Keys.deviceIdentifier) {
            return storedId
        }
        
        // Create and store new UUID
        let newId = UUID().uuidString
        defaults.set(newId, forKey: UserDefaults.Keys.deviceIdentifier)
        return newId
    }
    
    /// Try to get the Mac serial number
    private static func getMacSerialNumber() -> String? {
        let platformExpert = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        if platformExpert == 0 { return nil }
        
        defer { IOObjectRelease(platformExpert) }
        
        if let serialNumber = IORegistryEntryCreateCFProperty(platformExpert, "IOPlatformSerialNumber" as CFString, kCFAllocatorDefault, 0) {
            return (serialNumber.takeRetainedValue() as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return nil
    }
}
