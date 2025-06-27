import Services
import SwiftUI
import AnytypeCore

enum PropertySearchData: SearchDataProtocol {
    case existing(PropertyDetails)
    case new(SupportedPropertyFormat)
    
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
            details.iconImage ?? nil
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

extension PropertyDetails: SearchDataProtocol {
    
    var iconImage: Icon? { Icon.asset(format.iconAsset) }
    
    var title: String { name }

    var mode: SerchDataPresentationMode { .minimal }
}
