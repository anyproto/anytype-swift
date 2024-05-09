import Foundation
import Services

struct GlobalSearchDataSection: Identifiable {
    let id = UUID()
    let searchData: [GlobalSearchData]
    let sectionConfig: SectionConfig?
    
    init(searchData: [GlobalSearchData], sectionConfig: SectionConfig? = nil) {
        self.searchData = searchData
        self.sectionConfig = sectionConfig
    }
    
    struct SectionConfig {
        let title: String
        let buttonTitle: String
    }
}

struct GlobalSearchData: Identifiable {
    let id = UUID()
    let iconImage: Icon?
    let title: String
    let highlights: [HighlightsData]
    let objectTypeName: String
    let backlinks: [String]
    let editorScreenData: EditorScreenData
}

enum HighlightsData: Identifiable, Hashable {
    case text(AttributedString)
    
    var id: Int { hashValue }
}
