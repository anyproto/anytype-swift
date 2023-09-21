import Foundation
import ProtobufMessages

public extension RelationLinksStorageProtocol {

    func ammend(data: Anytype_Event.Object.Relations.Amend) {
        amend(relationLinks: data.relationLinks.map { RelationLink(middlewareRelationLink: $0) })
    }
    
    func remove(data: Anytype_Event.Object.Relations.Remove) {
        remove(relationKeys: data.relationKeys)
    }
}
