import BlocksModels
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
        .textPrimary
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
        let layout = details.layoutValue
        if layout == .todo {
            return .todo(details.isDone)
        } else {
            return details.icon.flatMap { .icon($0) } ?? .placeholder(title.first)
        }
    }
    
    var viewType: EditorViewType {
        details.editorViewType
    }
    
}
