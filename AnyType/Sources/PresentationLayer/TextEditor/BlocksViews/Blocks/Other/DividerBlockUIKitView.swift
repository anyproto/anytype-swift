import UIKit
import Combine
import BlocksModels

struct DividerBlockUIKitViewStateConverter {
    typealias Model = BlockContent.Divider.Style
    typealias OurModel = DividerBlockUIKitViewState.Style
    
    static func asModel(_ value: OurModel) -> Model? {
        switch value {
        case .line: return .line
        case .dots: return .dots
        }
    }
    
    static func asOurModel(_ value: Model) -> OurModel? {
        switch value {
        case .line: return .line
        case .dots: return .dots
        }
    }
}

struct DividerBlockUIKitViewState {
    enum Style {
        case line, dots
    }
    
    var style: Style = .line
}
