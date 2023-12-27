import Foundation
import Services

extension NodeUsageInfo {
    static var placeholder: NodeUsageInfo {
        NodeUsageInfo(node: NodeUsage(filesCount: 0, cidsCount: 0, bytesUsage: 0, bytesLeft: 0, bytesLimit: 10, localBytesUsage: 0), spaces: [])
    }
}
