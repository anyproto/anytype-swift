import Foundation
import Services

struct SearchWithMetaModel: Identifiable, Hashable {
    let id: String
    let iconImage: Icon
    let title: AttributedString
    let highlights: [HighlightsData]
    let objectTypeName: String
    let editorScreenData: ScreenData
    let score: String
    let canArchive: Bool
    // Set for cross-space results in global search - "in <Space>" caption
    let spaceCaption: SearchSpaceCaption?
    // Groups the empty-query browse by day
    let lastModifiedDate: Date?
}

struct SearchSpaceCaption: Hashable {
    let spaceId: String
    let name: String
}

enum HighlightsData: Identifiable, Hashable {
    case text(AttributedString)
    case status(name: String, option: Property.Status.Option)
    case tag(name: String, option: Property.Tag.Option)
    
    var id: Int { hashValue }
}
