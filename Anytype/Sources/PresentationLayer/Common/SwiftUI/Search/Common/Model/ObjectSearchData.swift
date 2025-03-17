import Services
import SwiftUI
import AnytypeCore

struct ObjectSearchData: SearchDataProtocol {
    
    let id = UUID()
    
    let title: String
    let description: String
    let callout: String
    
    let blockId: String
    
    let details: ObjectDetails
    
    init(details: ObjectDetails) {
        self.details = details
        self.title = details.title
        self.description = details.description
        self.callout = details.objectType.displayName
        
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

    var iconImage: Icon? {
        details.objectIconImage
    }
}
