import Services
import SwiftUI
import AnytypeCore

struct RelationSearchData: SearchDataProtocol {
    
    let id = UUID()
    
    let title: String
    let iconImage: Icon?
    
    let mode = SerchDataPresentationMode.minimal
    
    let details: RelationDetails
    
    init(details: RelationDetails) {
        self.title = details.name
        self.iconImage = Icon.asset(details.format.iconAsset)
        self.details = details
    }
}
