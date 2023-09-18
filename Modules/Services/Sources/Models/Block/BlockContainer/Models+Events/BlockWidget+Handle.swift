import Foundation
import ProtobufMessages

extension BlockWidget {
    func handleSetWidget(data: Anytype_Event.Block.Set.Widget) -> Self {
        
        var newData = self
        
        if data.hasLayout, let newLayout = try? data.layout.value.asModel {
            newData.layout = newLayout
        }
        
        if data.hasLimit {
            newData.limit = Int(data.limit.value)
        }
        
        if data.hasViewID {
            newData.viewId = data.viewID.value
        }
        
        return newData
    }
}
