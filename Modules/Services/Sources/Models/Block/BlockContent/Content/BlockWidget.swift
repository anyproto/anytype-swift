import Foundation
import ProtobufMessages

public typealias BlockWidget = Anytype_Model_Block.Content.Widget

// Temporary.  Until the middle adds to the contract
public extension BlockWidget.Layout {
    static let view = BlockWidget.Layout.UNRECOGNIZED(4)
}
