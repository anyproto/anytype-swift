import Foundation
import UIKit

enum BlockViewType: Hashable, Comparable {
    case text(Text), list(List), objects(Objects), tool(Tool), other(Other)
    
    enum Text: Comparable {
        case text, h1, h2, h3, highlighted
    }

    enum List: Comparable {
        case checkbox, bulleted, numbered, toggle
    }
    
    enum Objects: Comparable {
        case page, file, picture, video, bookmark, linkToObject
    }

    enum Tool: Comparable {
        case contact, database, set, task
    }

    enum Other: Comparable {
        case lineDivider, dotsDivider, code
    }
}
