import SwiftUI
import Services
import AnytypeCore

struct LinkToObjectSearchData: SearchDataProtocol {
    let id = UUID()
    
    let title: String
    let iconImage: Icon?
    
    let searchKind: LinkToObjectSearchViewModel.SearchKind
    let mode: SerchDataPresentationMode

    init(details: ObjectDetails, searchKind: LinkToObjectSearchViewModel.SearchKind? = nil) {
        self.title = details.pluralTitle
        self.iconImage = details.objectIconImage
        
        
        let searchKind = searchKind ?? .object(details.id)
        self.searchKind = searchKind
        
        self.mode = .full(
            descriptionInfo: (searchKind.shouldShowDescription && details.description.isNotEmpty) ? SearchDataDescriptionInfo(
                description: details.description,
                descriptionTextColor: .Text.primary,
                descriptionFont: .relation3Regular
            ) : nil,
            callout: (searchKind.shouldShowCallout && details.objectType.displayName.isNotEmpty) ? details.objectType.displayName : nil
        )
    }

    init(searchKind: LinkToObjectSearchViewModel.SearchKind, searchTitle: String, iconImage: Icon?) {
        self.title = searchTitle
        self.iconImage = iconImage
        self.searchKind = searchKind
        
        self.mode = .full(descriptionInfo: nil, callout: nil)
    }
    
}

private extension LinkToObjectSearchViewModel.SearchKind {
    var shouldShowDescription: Bool {
        switch self {
        case .object, .openObject: true
        case .web, .createObject, .removeLink, .copyLink, .openURL: false
        }
    }
    
    var shouldShowCallout: Bool {
        switch self {
        case .object: true
        case .web, .createObject, .openURL, .openObject, .removeLink, .copyLink: false
        }
    }
}
