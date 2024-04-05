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
    let description: String
    let objectTypeName: String
    let backlinks: [String]
    let editorScreenData: EditorScreenData
    
    init(details: ObjectDetails) {
        self.iconImage = details.objectIconImage
        self.title = details.title
        self.description = details.description
        self.objectTypeName = details.objectType.name
        self.backlinks = details.backlinks
        self.editorScreenData = details.editorScreenData()
    }
}
