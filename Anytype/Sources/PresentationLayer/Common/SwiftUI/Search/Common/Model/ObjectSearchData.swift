import Services
import SwiftUI
import AnytypeCore

struct ObjectSearchData: SearchDataProtocol {
    
    let id = UUID()
    
    let title: String
    let description: String
    let callout: String
    let typeId: String
    
    let blockId: String
    
    let screenData: ScreenData
    
    let details: ObjectDetails
    
    init(details: ObjectDetails) {
        self.details = details
        self.title = details.title
        self.description = details.description
        self.callout = details.objectType.name
        self.typeId = details.objectType.id
        
        self.blockId = details.id
        self.screenData = details.screenData()
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

    var iconImage: Icon? {
        details.objectIconImage
    }
}
