import Foundation
import ProtobufMessages

public extension RelationKeysStorageProtocol {

    func ammend(data: Anytype_Event.Object.Relations.Amend) {
        amend(relationKeys: data.relationLinks.map { $0.key })
    }
    
    func remove(data: Anytype_Event.Object.Relations.Remove) {
        remove(relationKeys: data.relationKeys)
    }
}
