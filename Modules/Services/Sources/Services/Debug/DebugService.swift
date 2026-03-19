import Foundation
import ProtobufMessages
import AnytypeCore
import Combine


public enum DebugRunProfilerState: Codable {
    case empty
    case inProgress
    case done(url: URL)
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
            }).invoke().path

            let url = URL(fileURLWithPath: path)
            await storage.setDebugRunProfilerData(.done(url: url))
        }
    }
}
