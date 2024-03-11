import Foundation
import ProtobufMessages

public struct SpaceUsage {
    public var spaceID: String
    public var filesCount: Int64
    public var cidsCount: Int64
    public var bytesUsage: Int64
}

extension SpaceUsage {
    init(from data: Anytype_Rpc.File.NodeUsage.Response.Space) {
        self.spaceID = data.spaceID
        self.filesCount = Int64(data.filesCount)
        self.cidsCount = Int64(data.cidsCount)
        self.bytesUsage = Int64(data.bytesUsage)
    }
}
