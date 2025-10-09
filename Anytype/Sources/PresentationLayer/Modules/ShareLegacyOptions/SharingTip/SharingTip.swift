import Foundation
import TipKit

struct SharingTip: Tip {
    @Parameter
    static var didCopyText: Bool = false
    
    var title: Text {
        Text(verbatim: Loc.Sharing.Navigation.title)
    }
    
    var options: [any TipOption] {
        Tip.MaxDisplayCount(1)
    }
    
    var rules: [Rule] {
        [ #Rule(Self.$didCopyText) { $0 == true } ]
    }
}
