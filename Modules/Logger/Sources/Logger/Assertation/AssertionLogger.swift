import Logging

public protocol AssertionLoggerHandler: AnyObject {
    func log(_ message: String, domain: String, info: [String: Any])
}

public final class AssertionLogger {

    public static var shared = AssertionLogger()
    
    private let eventLogger = EventLogger(category: "Assertation")
    public var handler: AssertionLoggerHandler?
    
    private init() {}
    
    
    public func log(
        _ message: String,
        domain: String,
        info: [String: String],
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
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
        handler?.log(message, domain: domain, info: info)
    }
}
