import Foundation
import TipKit

@available(iOS 17.0, *)
struct SharingTip: Tip {
    @Parameter
    static var didCopyText: Bool = false
    
    var title: Text {
        Text(verbatim: .empty)
    }
    
    var options: [TipOption] {
        Tip.MaxDisplayCount(1)
    }
    
    var rules: [Rule] {
        [ #Rule(Self.$didCopyText) { $0 == true } ]
    }
}
