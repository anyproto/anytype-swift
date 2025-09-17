import Foundation
import TipKit

@available(iOS 17.0, *)
struct ChatCreationTip: Tip {
    var title: Text {
        Text(verbatim: Loc.createChat)
    }
    
    var options: [any TipOption] {
        Tip.MaxDisplayCount(1)
    }
}
