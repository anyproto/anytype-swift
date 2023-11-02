import Foundation
import ProtobufMessages

struct NodeUsageInfo {
    var node: NodeUsage
    var spaces: [SpaceUsage]
}

extension NodeUsageInfo {
    init(from data: Anytype_Rpc.File.NodeUsage.Response) {
        self.node = NodeUsage(from: data.usage)
        self.spaces = data.spaces.map { SpaceUsage(from: $0) }
    }
}

extension NodeUsageInfo {
    static var zero: NodeUsageInfo {
        NodeUsageInfo(node: NodeUsage(filesCount: 0, cidsCount: 0, bytesUsage: 0, bytesLeft: 0, bytesLimit: 0, localBytesUsage: 0), spaces: [])
    }
}
