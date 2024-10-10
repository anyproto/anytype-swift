import Foundation
import TipKit

@available(iOS 17.0, *)
struct SpaceShareTip: Tip {
    @Parameter
    static var didOpenPrivateSpace: Bool = false
    @Parameter
    static var didShowUserWarningAlert: Bool = false
    
    var title: Text {
        Text(verbatim: Loc.unknown)
    }
    
    var options: [any TipOption] {
        Tip.MaxDisplayCount(1)
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.$didOpenPrivateSpace) { $0 == true },
            // avoiding clash with UserWarningAlert
            #Rule(Self.$didShowUserWarningAlert) { $0 == true }
        ]
    }
}
