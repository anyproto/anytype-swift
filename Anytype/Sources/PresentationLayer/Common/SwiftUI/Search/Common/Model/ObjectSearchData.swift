import Services
import SwiftUI
import AnytypeCore

struct ObjectSearchData: SearchDataProtocol {
    let id = UUID()
    
    let title: String
    let iconImage: Icon?
    
    let mode: SerchDataPresentationMode
    
    let details: ObjectDetails
    
    init(details: ObjectDetails) {
        self.title = FeatureFlags.pluralNames ? details.pluralTitle : details.title
        self.iconImage =  details.objectIconImage
        self.details = details
        
        let descriptionInfo = details.description.isNotEmpty ? SearchDataDescriptionInfo(
            description: details.description,
            descriptionTextColor: .Text.primary,
            descriptionFont: .relation3Regular
        ) : nil
        
        self.mode = .full(
            descriptionInfo: descriptionInfo,
            callout: details.objectType.displayName.isNotEmpty ? details.objectType.displayName : nil
        )
        
    }
}

