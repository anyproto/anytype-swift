import Logging

public final class AnalyticsLogger: Sendable {

    public static let shared = AnalyticsLogger()
    
    private let eventLogger = EventLogger(category: "Analytics")

    private init() {}
        
    public func log(
        _ eventName: String,
        info: [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        
        let infoText = info?.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
        let message = [eventName, infoText].compactMap { $0 }.joined(separator: "\n")
        
        eventLogger.log(
            level: .info,
            message: "Analytics event: \(message)",
            file: file,
            function: function,
            line: line
        )
    }
}
