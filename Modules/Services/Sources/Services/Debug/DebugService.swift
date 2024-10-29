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
    
    @MainActor
    @Published private var _debugRunProfilerData = DebugRunProfilerState.empty
    var debugRunProfilerData: AnyPublisher<DebugRunProfilerState, Never> { $_debugRunProfilerData.eraseToAnyPublisher() }
    
    @MainActor @UserDefault("ShouldRunDebugProfilerOnNextStartup", defaultValue: false)
    var shouldRunDebugProfilerOnNextStartup: Bool
    
    func startDebugRunProfilerOnStartupIfNeeded() {
        if shouldRunDebugProfilerOnNextStartup {
            startDebugRunProfiler()
            shouldRunDebugProfilerOnNextStartup = false
        }
    }
    
    func startDebugRunProfiler() {
        Task {
            Task { @MainActor in
                _debugRunProfilerData = .inProgress
            }
            
            let path = try await ClientCommands.debugRunProfiler(.with {
                $0.durationInSeconds = 60
            }).invoke().path

            Task { @MainActor in
                if let url = URL(string: path) {
                    _debugRunProfilerData = .done(url: url)
                } else {
                    _debugRunProfilerData = .empty
                }
            }
        }
    }
}
