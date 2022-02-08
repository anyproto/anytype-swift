import BlocksModels
import SwiftUI

struct ObjectSearchData: SearchDataProtocol {
    let id = UUID()

    let searchKind: SearchKind
    private let details: ObjectDetails

    let blockId: BlockId
    let searchTitle: String
    let description: String
    var shouldShowDescription: Bool { true }

    var shouldShowCallout: Bool {
        switch searchKind {
        case .objects:
            return true
        case .objectTypes:
            return false
        }
    }

    var descriptionTextColor: Color {
        switch searchKind {
        case .objects:
            return .textPrimary
        case .objectTypes:
            return .textSecondary
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
            return details.icon.flatMap { .icon($0) } ?? .placeholder(searchTitle.first)
        }
    }

    var callout: String {
        details.objectType.name
    }
    
    var viewType: EditorViewType {
        details.editorViewType
    }

    init(searchKind: SearchKind, details: ObjectDetails) {
        self.details = details
        self.searchKind = searchKind
        self.searchTitle = details.title
        self.description = details.description
        self.blockId = details.id
    }
}
