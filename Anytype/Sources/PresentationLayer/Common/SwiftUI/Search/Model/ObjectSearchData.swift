import Services
import SwiftUI
import AnytypeCore

struct ObjectSearchData: SearchDataProtocol {
    
    let id = UUID()
    
    let title: String
    let description: String
    let callout: String
    let typeId: String
    
    let blockId: BlockId
    
    let editorScreenData: EditorScreenData
    
    private let details: ObjectDetails
    
    init(details: ObjectDetails) {
        self.details = details
        self.title = details.title
        self.description = details.description
        self.callout = details.objectType.name
        self.typeId = details.objectType.id
        
        self.blockId = details.id
        self.editorScreenData = details.editorScreenData()
    }

}

extension ObjectSearchData {
    
    var shouldShowDescription: Bool {
        description.isNotEmpty
    }
    
    var descriptionTextColor: Color {
        .Text.primary
    }
    
    var descriptionFont: AnytypeFont {
        .relation3Regular
    }
    
    var shouldShowCallout: Bool {
        callout.isNotEmpty
    }
    
    var verticalInset: CGFloat {
        16
    }

    var usecase: ObjectIconImageUsecase {
        .dashboardSearch
    }

    var iconImage: ObjectIconImage? {
        FeatureFlags.deleteObjectPlaceholder ? details.objectIconImage : details.objectIconImageWithPlaceholder
    }
}
