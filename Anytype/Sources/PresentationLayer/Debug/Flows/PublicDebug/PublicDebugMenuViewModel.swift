import Foundation
import UIKit
import AnytypeCore
import Services
import ZIPFoundation


@MainActor
final class PublicDebugMenuViewModel: ObservableObject {
    
    @Published var shareUrlFile: URL?
    @Published var showZipPicker = false
    
    @Published var debugRunProfilerData = DebugRunProfilerState.empty
    
    @Injected(\.debugService)
    private var debugService: any DebugServiceProtocol
    @Injected(\.localAuthService)
    private var localAuthService: any LocalAuthServiceProtocol
    @Injected(\.localRepoService)
    private var localRepoService: any LocalRepoServiceProtocol
    @Injected(\.authService)
    private var authService: any AuthServiceProtocol
    @Injected(\.applicationStateService)
    private var applicationStateService: any ApplicationStateServiceProtocol
    
    var shouldRunDebugProfilerOnNextStartup: Bool {
        get {
            debugService.shouldRunDebugProfilerOnNextStartup
        } set {
            debugService.shouldRunDebugProfilerOnNextStartup = newValue
        }
    }
    
    init() {
        debugService.debugRunProfilerData.receiveOnMain().assign(to: &$debugRunProfilerData)
    }
    
    func getLocalStoreData() async throws {
        try await localAuthService.auth(reason: "Share local store")
        let path = try await debugService.exportLocalStore()
        let zipFile = FileManager.default.createTempDirectory().appendingPathComponent("localstore.zip")
        try FileManager.default.zipItem(at: URL(fileURLWithPath: path), to: zipFile)
        shareUrlFile = zipFile
    }
    
    func getGoroutinesData() async throws {
        shareUrlFile = try await debugService.exportStackGoroutinesZip()
    }
    
    func zipWorkingDirectory() {
        Task {
            try await localAuthService.auth(reason: "Share working directory")
            let zipFile = FileManager.default.createTempDirectory().appendingPathComponent("workingDirectory.zip")
            try FileManager.default.zipItem(at: localRepoService.middlewareRepoURL, to: zipFile)
            shareUrlFile = zipFile
        }
    }
    
    func unzipWorkingDirectory() {
        showZipPicker.toggle()
    }
    
    func onSelectUnzipFile(url: URL) {
        Task {
            let middlewareTempPath = FileManager.default.createTempDirectory()
            try FileManager.default.unzipItem(at: url, to: middlewareTempPath)
            try await authService.logout(removeData: false)
            applicationStateService.state = .initial
            let middlewareRepoURL = localRepoService.middlewareRepoURL
            try? FileManager.default.removeItem(at: middlewareRepoURL)
            try FileManager.default.moveItem(
                at: middlewareTempPath.appendingPathComponent(middlewareRepoURL.lastPathComponent),
                to: middlewareRepoURL
            )
        }
    }
    
    func onDebugRunProfiler() {
        debugService.startDebugRunProfiler()
    }
    
    func shareUrlContent(url: URL) {
        shareUrlFile = url
    }
    
    func debugStat() async throws {
        shareUrlFile = try await debugService.debugStat()
    }
}
