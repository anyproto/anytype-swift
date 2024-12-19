import Logging
import os

public protocol AssertionLoggerHandler: AnyObject, Sendable {
    func log(_ message: String, domain: String, info: [String: Any], tags: [String: String], file: String, function: String, line: UInt)
}

public final class AssertionLogger: @unchecked Sendable {

    public static let shared = AssertionLogger()
    
    private let eventLogger = EventLogger(category: "Assertation")
    private var handlers = [AssertionLoggerHandler]()
    private let lock = OSAllocatedUnfairLock()
    
    private init() {}
    
    public func addHandler(_ handler: AssertionLoggerHandler) {
        lock.lock()
        handlers.append(handler)
        lock.unlock()
    }
    
    public func log(
        _ message: String,
        domain: String,
        info: [String: String],
        tags: [String: String],
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        lock.lock()
        var metadata = info
        metadata["domain"] = domain
        
        let fullMessage = "\(domain): \(message)"
        eventLogger.log(
            level: .critical,
            message: fullMessage,
            metadata: metadata,
            file: file,
            function: function,
            line: line
        )
        handlers.forEach {
            $0.log(message, domain: domain, info: info, tags: tags, file: file, function: function, line: line)
        }
        lock.unlock()
    }
}
