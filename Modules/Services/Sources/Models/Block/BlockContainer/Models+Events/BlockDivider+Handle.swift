import Foundation
import ProtobufMessages

extension BlockDivider {
    func handleSetDiv(data: Anytype_Event.Block.Set.Div) -> Self {
        var newData = self
        
        if let newStyle = BlockDivider.Style(data.style.value) {
            newData.style = newStyle
        }
        
        return newData
    }
}
