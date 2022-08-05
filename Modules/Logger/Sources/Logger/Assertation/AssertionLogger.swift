import Logging

public protocol AssertionLoggerHandler {
    func log(_ message: String, domain: String)
}

public final class AssertionLogger {

    public static var shared = AssertionLogger()
    
    private let eventLogger = EventLogger(category: "Assertation")
    public var handler: AssertionLoggerHandler?
    
    private init() {}
    
    public func log(
        _ message: String,
        domain: String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        let fullMessage = "\(domain): \(message)"
        eventLogger.log(
            level: .critical,
            message: fullMessage,
            metadata: ["domain": Logger.MetadataValue(stringLiteral: domain)],
            file: file,
            function: function,
            line: line
        )
        handler?.log(message, domain: domain)
    }
}
