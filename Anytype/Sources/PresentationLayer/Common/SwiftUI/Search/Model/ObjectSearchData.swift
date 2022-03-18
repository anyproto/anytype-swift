import BlocksModels
import SwiftUI

struct ObjectSearchData: SearchDataProtocol {
    
    let id = UUID()
    
    let title: String
    let description: String
    let callout: String
    
    let blockId: BlockId
    
    private let searchKind: SearchKind
    private let details: ObjectDetails
    
    init(searchKind: SearchKind, details: ObjectDetails) {
        self.details = details
        self.searchKind = searchKind
        self.title = details.title
        self.description = details.description
        self.callout = details.objectType.name
        
        self.blockId = details.id
    }

}

extension ObjectSearchData {
    
    var shouldShowDescription: Bool {
        description.isNotEmpty
    }
    
    var descriptionTextColor: Color {
        switch searchKind {
        case .objects: return .textPrimary
        case .objectTypes: return .textSecondary
        }
    }
    
    var descriptionFont: AnytypeFont {
        switch searchKind {
        case .objects: return .relation3Regular
        case .objectTypes: return .relation2Regular
        }
    }
    
    var shouldShowCallout: Bool {
        switch searchKind {
        case .objects: return callout.isNotEmpty
        case .objectTypes: return false
        }
    }
    
    var verticalInset: CGFloat {
        switch searchKind {
        case .objects: return 16
        case .objectTypes: return 20
        }
    }

    var usecase: ObjectIconImageUsecase {
        .dashboardSearch
    }

    var iconImage: ObjectIconImage {
        let layout = details.layout
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
