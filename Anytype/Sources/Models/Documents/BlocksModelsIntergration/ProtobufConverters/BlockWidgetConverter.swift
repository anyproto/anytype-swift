import Foundation
import BlocksModels
import ProtobufMessages

extension Anytype_Model_Block.Content.Widget {
    var blockContent: BlockContent {
        return .widget(BlockWidget(layout: .link))
    }
}


extension BlockWidget {
    var asMiddleware: Anytype_Model_Block.OneOf_Content {
        .widget(Anytype_Model_Block.Content.Widget())
    }
  
}
