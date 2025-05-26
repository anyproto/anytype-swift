import Services
import SwiftUI
import AnytypeCore

enum RelationSearchData: SearchDataProtocol {
    case existing(RelationDetails)
    case new(SupportedRelationFormat)
    
    var id: String {
        switch self {
        case .existing(let details):
            details.id
        case .new(let format):
            format.id
        }
    }
    
    var iconImage: Icon? {
        switch self {
        case .existing(let details):
            details.iconImage
        case .new(let format):
            Icon.asset(format.iconAsset)
        }
    }
    var title: String {
        switch self {
        case .existing(let details):
            details.title
        case .new(let format):
            format.title
        }
    }

    var mode: SerchDataPresentationMode { .minimal }
}

extension RelationDetails: SearchDataProtocol {
    
    var iconImage: Icon? { Icon.asset(format.iconAsset) }
    
    var title: String { name }

    var mode: SerchDataPresentationMode { .minimal }
}
