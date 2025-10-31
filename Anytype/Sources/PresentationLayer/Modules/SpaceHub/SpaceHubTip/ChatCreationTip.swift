import Foundation
import TipKit

struct ChatCreationTip: Tip {
    var title: Text {
        Text(verbatim: Loc.createChat)
    }
    
    var options: [any TipOption] {
        Tip.MaxDisplayCount(1)
    }
}
