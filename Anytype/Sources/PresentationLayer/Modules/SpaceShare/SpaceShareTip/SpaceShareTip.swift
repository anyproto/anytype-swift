import Foundation
import TipKit

@available(iOS 17.0, *)
struct SpaceShareTip: Tip {
    @Parameter
    static var didOpenPrivateSpace: Bool = false
    
    var title: Text {
        Text(verbatim: Loc.unknown)
    }
    
    var options: [TipOption] {
        Tip.MaxDisplayCount(1)
    }
    
    var rules: [Rule] {
        [ #Rule(Self.$didOpenPrivateSpace) { $0 == true } ]
    }
}
