import SwiftUI
import Services
import AnytypeCore

struct LinkToObjectSearchData: SearchDataProtocol {
    let id = UUID()

    let searchKind: LinkToObjectSearchViewModel.SearchKind
    
    let title: String
    let description: String
    let callout: String
    let typeId: String
    
    let iconImage: Icon?
    
    let screenData: ScreenData

    init(details: ObjectDetails, searchKind: LinkToObjectSearchViewModel.SearchKind? = nil) {
        self.searchKind = searchKind ?? .object(details.id)
        self.title = details.title
        self.description = details.description
        self.callout = details.objectType.displayName
        self.typeId = details.objectType.id
        self.iconImage = details.objectIconImage
        self.screenData = details.screenData()
    }

    init(searchKind: LinkToObjectSearchViewModel.SearchKind, searchTitle: String, iconImage: Icon?) {
        self.searchKind = searchKind
        self.title = searchTitle
        self.iconImage = iconImage
        self.description = ""
        self.callout = ""
        self.typeId = ""
        self.screenData = .editor(.page(EditorPageObject(objectId: "", spaceId: "")))
    }
    
}

extension LinkToObjectSearchData {
    
    var shouldShowDescription: Bool {
        switch searchKind {
        case .object, .openObject: return description.isNotEmpty
        case .web, .createObject, .removeLink, .copyLink, .openURL: return false
        }
    }
    
    var descriptionTextColor: Color {
        .Text.primary
    }
    
    var descriptionFont: AnytypeFont {
        .relation3Regular
    }

    var shouldShowCallout: Bool {
        switch searchKind {
        case .object: return callout.isNotEmpty
        case .web, .createObject, .openURL, .openObject, .removeLink, .copyLink: return false
        }
    }
    
    var verticalInset: CGFloat {
        20
    }
}
