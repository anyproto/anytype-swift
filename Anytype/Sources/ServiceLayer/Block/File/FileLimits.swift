import Foundation

struct FileLimits {
    var filesCount: Int64
    var cidsCount: Int64
    var bytesUsage: Int64
    var bytesLeft: Int64
    var bytesLimit: Int64
    var localBytesUsage: Int64
}

extension FileLimits {
    static var zero: FileLimits {
        FileLimits(filesCount: 0, cidsCount: 0, bytesUsage: 0, bytesLeft: 0, bytesLimit: 0, localBytesUsage: 0)
    }
}
