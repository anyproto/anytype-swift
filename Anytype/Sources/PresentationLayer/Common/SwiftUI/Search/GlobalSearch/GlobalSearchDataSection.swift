import Foundation
import Services

struct GlobalSearchDataSection: Identifiable, Hashable {
    let searchData: [GlobalSearchData]
    let sectionConfig: SectionConfig?
    
    var id: Int { hashValue }
    
    init(searchData: [GlobalSearchData], sectionConfig: SectionConfig? = nil) {
        self.searchData = searchData
        self.sectionConfig = sectionConfig
    }
    
    struct SectionConfig: Hashable {
        let title: String
        let buttonTitle: String
    }
}

struct GlobalSearchData: Identifiable, Hashable {
    let iconImage: Icon?
    let title: String
    let highlights: [HighlightsData]
    let objectTypeName: String
    let relatedLinks: [String]
    let editorScreenData: EditorScreenData
    let score: String
    
    var id: Int { hashValue }
}

enum HighlightsData: Identifiable, Hashable {
    case text(AttributedString)
    case status(name: String, option: Relation.Status.Option)
    case tag(name: String, option: Relation.Tag.Option)
    
    var id: Int { hashValue }
}
