import Foundation
import ProtobufMessages
import AnytypeCore

extension BlockBookmark {
    func handleSetBookmark(data: Anytype_Event.Block.Set.Bookmark) -> Self {
        var newData = self
        
        if data.hasURL {
            newData.source = AnytypeURL(string: data.url.value)
        }
        
        if data.hasTitle {
            newData.title = data.title.value
        }

        if data.hasDescription_p {
            newData.theDescription = data.description_p.value
        }

        if data.hasImageHash {
            newData.imageHash = data.imageHash.value
        }

        if data.hasFaviconHash {
            newData.faviconHash = data.faviconHash.value
        }

        if data.hasType, let newType = data.type.value.asModel {
            newData.type = newType
        }
        
        if data.hasTargetObjectID {
            newData.targetObjectID = data.targetObjectID.value
        }
        
        if data.hasState {
            newData.state = data.state.value.asModel
        }
        
        return newData
    }
}
