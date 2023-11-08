import Foundation
import ProtobufMessages

struct NodeUsage {
    var filesCount: Int64
    var cidsCount: Int64
    var bytesUsage: Int64
    var bytesLeft: Int64
    var bytesLimit: Int64
    var localBytesUsage: Int64
}

extension NodeUsage {
    init(from data: Anytype_Rpc.File.NodeUsage.Response.Usage) {
        self.filesCount = Int64(data.filesCount)
        self.cidsCount = Int64(data.cidsCount)
        self.bytesUsage = Int64(data.bytesUsage)
        self.bytesLeft = Int64(data.bytesLeft)
        self.bytesLimit = Int64(data.bytesLimit)
        self.localBytesUsage = Int64(data.localBytesUsage)
    }
}
