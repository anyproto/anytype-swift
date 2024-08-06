import Foundation
import Logger

extension AssertionLogger {
    @inlinable
    public func log(
        _ message: String,
        info: [String: String] = [:],
        tags: [String: String] = [:],
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        let domain = URL(string: file)?.deletingPathExtension().lastPathComponent ?? function
        log(message, domain: domain, info: info, tags: tags, file: file, function: function, line: line)
    }
}
