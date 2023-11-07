import Foundation
import ProtobufMessages

struct SpaceUsage {
    var spaceID: String
    var filesCount: Int64
    var cidsCount: Int64
    var bytesUsage: Int64
}

extension SpaceUsage {
    init(from data: Anytype_Rpc.File.NodeUsage.Response.Space) {
        self.spaceID = data.spaceID
        self.filesCount = Int64(data.filesCount)
        self.cidsCount = Int64(data.cidsCount)
        self.bytesUsage = Int64(data.bytesUsage)
    }
}
