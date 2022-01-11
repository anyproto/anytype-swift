import SwiftUI
import BlocksModels

struct LinkToObjectSearchData: SearchDataProtocol {
    let id = UUID()

    let searchKind: LinkToObjectSearchViewModel.SearchKind
    let searchTitle: String
    let description: String
    let iconImage: ObjectIconImage
    let callout: String
    let viewType: EditorViewType


    var shouldShowDescription: Bool {
        switch searchKind {
        case .object: return true
        case .web, .createObject: return false
        }
    }

    var shouldShowCallout: Bool {
        switch searchKind {
        case .object: return true
        case .web, .createObject: return false
        }
    }

    var descriptionTextColor: Color {
        return .textPrimary
    }

    var usecase: ObjectIconImageUsecase {
        switch searchKind {
        case .object: return .dashboardSearch
        case .web, .createObject: return .mention(.heading)
        }
    }
    
    init(details: ObjectDetails) {
        self.searchKind = .object(details.id)
        self.searchTitle = details.title
        self.description = details.description
        self.viewType = details.editorViewType

        let layout = details.layout
        if layout == .todo {
            self.iconImage =  .todo(details.isDone)
        } else {
            self.iconImage = details.icon.flatMap { .icon($0) } ?? .placeholder(searchTitle.first)
        }

        callout = details.objectType.name
    }

    init(searchKind: LinkToObjectSearchViewModel.SearchKind, searchTitle: String, iconImage: ObjectIconImage) {
        self.searchKind = searchKind
        self.searchTitle = searchTitle
        self.iconImage = iconImage
        self.description = ""
        self.callout = ""
        self.viewType = .page
    }
}
