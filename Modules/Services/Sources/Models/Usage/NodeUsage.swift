import Foundation
import ProtobufMessages

public struct NodeUsage {
    public var filesCount: Int64
    public var cidsCount: Int64
    public var bytesUsage: Int64
    public var bytesLeft: Int64
    public var bytesLimit: Int64
    public var localBytesUsage: Int64
    
    public init(filesCount: Int64, cidsCount: Int64, bytesUsage: Int64, bytesLeft: Int64, bytesLimit: Int64, localBytesUsage: Int64) {
        self.filesCount = filesCount
        self.cidsCount = cidsCount
        self.bytesUsage = bytesUsage
        self.bytesLeft = bytesLeft
        self.bytesLimit = bytesLimit
        self.localBytesUsage = localBytesUsage
    }
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
