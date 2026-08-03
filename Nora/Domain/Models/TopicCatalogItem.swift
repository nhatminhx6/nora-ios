import Foundation

struct TopicCatalogItem: Identifiable, Codable, Equatable, Sendable {
    let key: String
    let name: String
    let description: String
    let category: TopicCategory
    let symbol: String
    let refinementLabel: String
    let refinementPlaceholder: String

    var id: String { key }
}
