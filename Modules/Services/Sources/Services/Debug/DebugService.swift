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
