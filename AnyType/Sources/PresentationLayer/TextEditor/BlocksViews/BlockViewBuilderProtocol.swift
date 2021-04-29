import SwiftUI

/// Define builder for block view in the block's view list
protocol BlockViewBuilderProtocol: AnyObject {
    typealias BlockID = String
    
    var blockId: BlockID { get }
    var diffable: AnyHashable { get }
    
    func buildUIView() -> UIView
}
