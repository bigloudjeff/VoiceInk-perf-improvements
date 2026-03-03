import Foundation

protocol APIKeyProviding {
 @discardableResult
 func saveAPIKey(_ key: String, forProvider provider: String) -> Bool
 func getAPIKey(forProvider provider: String) -> String?
 @discardableResult
 func deleteAPIKey(forProvider provider: String) -> Bool
 func hasAPIKey(forProvider provider: String) -> Bool

 @discardableResult
 func saveCustomModelAPIKey(_ key: String, forModelId modelId: UUID) -> Bool
 func getCustomModelAPIKey(forModelId modelId: UUID) -> String?
 @discardableResult
 func deleteCustomModelAPIKey(forModelId modelId: UUID) -> Bool
}
