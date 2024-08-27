import Foundation
import SwiftUI
import AnytypeCore

protocol SpaceSetupManagerProtocol :AnyObject {
    func setActiveSpace(sceneId: String, spaceId: String) async throws
    func registryHome(sceneId: String, manager: any HomeSpaceSetupManagerProtocol) async
}

actor SpaceSetupManager: SpaceSetupManagerProtocol {
    
    private struct WeakValue {
        weak var manager: (any HomeSpaceSetupManagerProtocol)?
    }
    
    private var cache: [String: WeakValue] = [:]
    
    // MARK: - SpaceSetupManagerProtocol
    
    func setActiveSpace(sceneId: String, spaceId: String) async throws {
        guard let manager = cache[sceneId]?.manager else {
            anytypeAssertionFailure("Manager not found")
            return
        }
        try await manager.setActiveSpace(spaceId: spaceId)
    }
    
    func registryHome(sceneId: String, manager: any HomeSpaceSetupManagerProtocol) {
        if cache[sceneId]?.manager != nil {
            anytypeAssertionFailure("Already cache")
        }
        
        cache[sceneId] = WeakValue(manager: manager)
    }
}
