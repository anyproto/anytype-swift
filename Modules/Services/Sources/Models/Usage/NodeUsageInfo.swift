import Foundation
import ProtobufMessages

public struct NodeUsageInfo {
    public var node: NodeUsage
    public var spaces: [SpaceUsage]
    
    public init(node: NodeUsage, spaces: [SpaceUsage]) {
        self.node = node
        self.spaces = spaces
    }
}

extension NodeUsageInfo {
    init(from data: Anytype_Rpc.File.NodeUsage.Response) {
        self.node = NodeUsage(from: data.usage)
        self.spaces = data.spaces.map { SpaceUsage(from: $0) }
    }
}
