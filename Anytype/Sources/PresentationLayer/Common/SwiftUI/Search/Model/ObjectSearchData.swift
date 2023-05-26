import Services
import SwiftUI

struct ObjectSearchData: SearchDataProtocol {
    
    let id = UUID()
    
    let title: String
    let description: String
    let callout: String
    let typeId: String
    
    let blockId: BlockId
    
    private let details: ObjectDetails
    
    init(details: ObjectDetails) {
        self.details = details
        self.title = details.title
        self.description = details.description
        self.callout = details.objectType.name
        self.typeId = details.objectType.id
        
        self.blockId = details.id
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

    var iconImage: ObjectIconImage {
        details.objectIconImageWithPlaceholder
    }
    
    var viewType: EditorViewType {
        details.editorViewType
    }
    
}
