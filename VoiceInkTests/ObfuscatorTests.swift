import Testing
import Foundation
@testable import VoiceInk

struct ObfuscatorTests {

 @Test func roundTripEncodeDecode() {
 let original = "my-secret-api-key-12345"
 let salt = "device-serial-abc"
 let encoded = Obfuscator.encode(original, salt: salt)
 let decoded = Obfuscator.decode(encoded, salt: salt)
 #expect(decoded == original)
 }

 @Test func encodedDiffersFromOriginal() {
 let original = "secret"
 let salt = "salt"
 let encoded = Obfuscator.encode(original, salt: salt)
 #expect(encoded != original)
 }

 @Test func wrongSaltFailsDecode() {
 let original = "secret"
 let encoded = Obfuscator.encode(original, salt: "correct-salt")
 let decoded = Obfuscator.decode(encoded, salt: "wrong-salt")
 #expect(decoded != original)
 }

 @Test func emptyStringRoundTrip() {
 let encoded = Obfuscator.encode("", salt: "salt")
 let decoded = Obfuscator.decode(encoded, salt: "salt")
 #expect(decoded == "")
 }

 @Test func emptySaltFallsBackToBase64() {
 let original = "test"
 let encoded = Obfuscator.encode(original, salt: "")
 let decoded = Obfuscator.decode(encoded, salt: "")
 #expect(decoded == original)
 }

 @Test func unicodeRoundTrip() {
 let original = "API密钥-тест-"
 let salt = "device123"
 let encoded = Obfuscator.encode(original, salt: salt)
 let decoded = Obfuscator.decode(encoded, salt: salt)
 #expect(decoded == original)
 }

 @Test func invalidBase64ReturnsNil() {
 let decoded = Obfuscator.decode("not-valid-base64!!!", salt: "salt")
 #expect(decoded == nil)
 }
}
