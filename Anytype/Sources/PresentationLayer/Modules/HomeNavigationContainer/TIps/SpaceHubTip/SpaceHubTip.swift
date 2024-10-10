import Foundation
import TipKit

@available(iOS 17.0, *)
struct SpaceHubTip: Tip {
    
    @Parameter
    static var didShowSpaceHub: Bool = false
    @Parameter
    static var didShowUserWarningAlert: Bool = false
    
    var title: Text {
        Text(Loc.unknown)
    }
    
    var options: [any TipOption] {
        Tip.MaxDisplayCount(1)
    }
    
    var rules: [Rule] {
        [
            #Rule(Self.$didShowSpaceHub) { $0 == true },
            // avoiding clash with UserWarningAlert
            #Rule(Self.$didShowUserWarningAlert) { $0 == true }
        ]
    }
}
