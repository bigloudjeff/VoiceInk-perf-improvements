import SwiftData

protocol WordReplacing {
 func applyReplacements(to text: String, using context: ModelContext) -> String
}
