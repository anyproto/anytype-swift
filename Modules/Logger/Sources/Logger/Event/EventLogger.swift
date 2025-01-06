import Foundation
import Logging
import Pulse
import PulseProxy

public final class EventLogger: Sendable {
    
    public static let `default` = EventLogger(category: .default)
    
    private let category: String
    private let loggerStore: LoggerStore
    
    public init(category: String) {
        self.category = category
        self.loggerStore = LoggerStore.shared
    }
    
    public static func setupLgger() {
        NetworkLogger.enableProxy()
    }
    
    public func log(
        level: Logger.Level,
        message: String,
        metadata: [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        loggerStore.storeMessage(
            label: category,
            level: level.pulseLevel,
            message: message,
            metadata: metadata?.mapValues { LoggerStore.MetadataValue.string($0) },
            file: file,
            function: function,
            line: line
        )
    }
    
    @MainActor
    public static func disableRemoteLogger() {
        RemoteLogger.shared.disable()
    }
}

public extension EventLogger {
    func debug(
        _ message: String,
        metadata: [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .debug, message: message, metadata: metadata, file: file, function: function, line: line)
    }

    func error(
        _ message: String,
        metadata: [String: String]? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        log(level: .error, message: message, metadata: metadata, file: file, function: function, line: line)
    }
}

private extension Logger.Level {
    var pulseLevel: LoggerStore.Level {
        switch self {
        case .trace:
            return .trace
        case .debug:
            return .debug
        case .info:
            return .info
        case .notice:
            return .notice
        case .warning:
            return .warning
        case .error:
            return .error
        case .critical:
            return .critical
        }
    }
}
