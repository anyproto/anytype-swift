import Foundation
import ProtobufMessages

extension BlockWidget {
    func handleSetWidget(data: Anytype_Event.Block.Set.Widget) -> Self {
        
        var newData = self
        
        if data.hasLayout {
            newData.layout = data.layout.value
        }
        
        if data.hasLimit {
            newData.limit = data.limit.value
        }
        
        if data.hasViewID {
            newData.viewID = data.viewID.value
        }
        
        return newData
    }
}
