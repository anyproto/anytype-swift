import Foundation
import ProtobufMessages
import AnytypeCore
import Combine


public enum DebugRunProfilerState: Codable {
    case empty
    case inProgress
    case done(url: URL)
}

public enum DebugProfilerReason: Sendable {
    case userRequest
    case thermalState(ThermalSeverity)
    case memoryPressure(MemorySeverity)

    public enum ThermalSeverity: Sendable {
        case serious
        case critical
    }

    public enum MemorySeverity: Sendable {
        case warning
        case critical
    }

    var desc: String {
        switch self {
        case .userRequest: return "User request"
        case .thermalState(.serious): return "iOS thermal state: serious"
        case .thermalState(.critical): return "iOS thermal state: critical"
        case .memoryPressure(.warning): return "iOS memory pressure: warning"
        case .memoryPressure(.critical): return "iOS memory pressure: critical"
        }
    }
}

public struct DebugReportResult: Sendable {
    public let path: String
    public let summary: String
    public let lastModifiedTs: Int

    public init(path: String, summary: String, lastModifiedTs: Int) {
        self.path = path
        self.summary = summary
        self.lastModifiedTs = lastModifiedTs
    }
}

public protocol DebugServiceProtocol: AnyObject, Sendable {
    func exportLocalStore() async throws -> String
    func exportStackGoroutines() async throws -> String
    func exportSpaceDebug(spaceId: String) async throws -> String
    func debugStat() async throws -> URL
    func runDebugServer() -> String

    @MainActor var shouldRunDebugProfilerOnNextStartup: Bool { get set }
    @MainActor func startDebugRunProfilerOnStartupIfNeeded()

    @MainActor var debugRunProfilerData: AnyPublisher<DebugRunProfilerState, Never> { get }
    func startDebugRunProfiler()

    func runProfiler(durationInSeconds: Int, reason: DebugProfilerReason) async
    func exportReport(dir: String, full: Bool) async throws -> DebugReportResult
    func cleanupReport(ts: Int) async
}

final class DebugService: ObservableObject, DebugServiceProtocol {
    
    @MainActor
    private final class Storage {
        
        @Published var debugRunProfilerData = DebugRunProfilerState.empty

        @MainActor @UserDefault("ShouldRunDebugProfilerOnNextStartup", defaultValue: false)
        var shouldRunDebugProfilerOnNextStartup: Bool

        func setDebugRunProfilerData(_ state: DebugRunProfilerState) {
            debugRunProfilerData = state
        }
        
        nonisolated init() {}
    }
    
    private let storage = Storage()
    
    public func exportLocalStore() async throws -> String {
        let tempDirString = FileManager.default.createTempDirectory().path
        
        let response = try await ClientCommands.debugExportLocalstore(.with {
            $0.path = tempDirString
        }).invoke()
        
        return response.path
    }
    
    public func exportStackGoroutines() async throws -> String {
        let tempDirString = FileManager.default.createTempDirectory().path
        
        try await ClientCommands.debugStackGoroutines(.with {
            $0.path = tempDirString
        }).invoke()
        
        return tempDirString
    }
    
    public func exportSpaceDebug(spaceId: String) async throws -> String {
        let result = try await ClientCommands.debugSpaceSummary(.with {
            $0.spaceID = spaceId
        }).invoke()
        return try result.jsonString()
    }
    
    public func debugStat() async throws -> URL {
        let jsonContent = try await ClientCommands.debugStat().invoke().jsonStat
        let jsonFile = FileManager.default.createTempDirectory().appendingPathComponent("debugStat.json")
        try jsonContent.write(to: jsonFile, atomically: true, encoding: .utf8)

        return jsonFile
    }

    public func runDebugServer() -> String {
        let port = "6060"
        DebugServerRunner.run(addr: "0.0.0.0:\(port)")
        let ip = Self.wifiIPAddress() ?? "127.0.0.1"
        return "http://\(ip):\(port)"
    }

    private static func wifiIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else { return nil }
        defer { freeifaddrs(ifaddr) }

        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            guard addrFamily == UInt8(AF_INET) else { continue }

            let name = String(cString: interface.ifa_name)
            guard name == "en0" else { continue }

            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            getnameinfo(
                interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                &hostname, socklen_t(hostname.count),
                nil, 0,
                NI_NUMERICHOST
            )
            address = String(cString: hostname)
        }

        return address
    }
    
    // MARK: - Profiling
    
    var debugRunProfilerData: AnyPublisher<DebugRunProfilerState, Never> { storage.$debugRunProfilerData.eraseToAnyPublisher() }
    
    @MainActor
    var shouldRunDebugProfilerOnNextStartup: Bool {
        get { storage.shouldRunDebugProfilerOnNextStartup }
        set { storage.shouldRunDebugProfilerOnNextStartup = newValue }
    }
    
    func startDebugRunProfilerOnStartupIfNeeded() {
        if shouldRunDebugProfilerOnNextStartup {
            startDebugRunProfiler()
            shouldRunDebugProfilerOnNextStartup = false
        }
    }
    
    func startDebugRunProfiler() {
        Task {
            await storage.setDebugRunProfilerData(.inProgress)

            let path = try await ClientCommands.debugRunProfiler(.with {
                $0.durationInSeconds = 60
                $0.reason = .userRequest
            }).invoke().path

            let url = URL(fileURLWithPath: path)
            await storage.setDebugRunProfilerData(.done(url: url))
        }
    }

    func runProfiler(durationInSeconds: Int, reason: DebugProfilerReason) async {
        _ = try? await ClientCommands.debugRunProfiler(.with {
            $0.durationInSeconds = Int32(durationInSeconds)
            $0.reason = reason.protoReason
            $0.reasonDesc = reason.desc
        }).invoke()
    }

    func exportReport(dir: String, full: Bool) async throws -> DebugReportResult {
        let response = try await ClientCommands.debugExportReport(.with {
            $0.dir = dir
            $0.full = full
        }).invoke()
        return DebugReportResult(
            path: response.path,
            summary: response.summary,
            lastModifiedTs: Int(response.lastModifiedTs)
        )
    }

    func cleanupReport(ts: Int) async {
        _ = try? await ClientCommands.debugCleanupReport(.with {
            $0.ts = Int64(ts)
        }).invoke()
    }
}

private extension DebugProfilerReason {
    var protoReason: Anytype_Rpc.Debug.RunProfiler.Request.Reason {
        switch self {
        case .userRequest: return .userRequest
        case .thermalState(.serious): return .thermalSerious
        case .thermalState(.critical): return .thermalCritical
        case .memoryPressure(.warning): return .memoryPressureWarn
        case .memoryPressure(.critical): return .memoryPressureCritical
        }
    }
}
