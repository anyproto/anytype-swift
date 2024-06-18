import Foundation
import ProtobufMessages

extension BlockFile {
    func handleSetFile(data: Anytype_Event.Block.Set.File) -> Self {
        var newData = self
        
        if data.hasType, let newContentType = FileContentType(data.type.value) {
            newData.contentType = newContentType
        }

        if data.hasState, let newState = data.state.value.asModel {
            newData.state = newState
        }
        
        if data.hasTargetObjectID {
            newData.metadata.targetObjectId = data.targetObjectID.value
        }
        
        return newData
    }
}
