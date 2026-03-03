import Foundation

protocol PowerModeProviding: AnyObject {
 var configurations: [PowerModeConfig] { get }
 var activeConfiguration: PowerModeConfig? { get }
 var currentActiveConfiguration: PowerModeConfig? { get }
 var enabledConfigurations: [PowerModeConfig] { get }

 func getConfiguration(with id: UUID) -> PowerModeConfig?
 func getConfigurationForURL(_ url: String) -> PowerModeConfig?
 func getConfigurationForApp(_ bundleId: String) -> PowerModeConfig?
 func getDefaultConfiguration() -> PowerModeConfig?
 func setActiveConfiguration(_ config: PowerModeConfig?)
 func isEmojiInUse(_ emoji: String) -> Bool
}
