import Foundation
import SwiftUI
import AnytypeCore

protocol SpaceSetupManagerProtocol :AnyObject {
    func setActiveSpace(homeSceneId: String, spaceId: String) async throws
    func registryHome(homeSceneId: String, manager: any HomeSpaceSetupManagerProtocol) async
}

actor SpaceSetupManager: SpaceSetupManagerProtocol {
    
    private struct WeakValue {
        weak var manager: (any HomeSpaceSetupManagerProtocol)?
    }
    
    private var cache: [String: WeakValue] = [:]
    
    // MARK: - SpaceSetupManagerProtocol
    
    func setActiveSpace(homeSceneId: String, spaceId: String) async throws {
        guard let manager = cache[homeSceneId]?.manager else {
            anytypeAssertionFailure("Manager not found")
            return
        }
        try await manager.setActiveSpace(spaceId: spaceId)
    }
    
    func registryHome(homeSceneId: String, manager: any HomeSpaceSetupManagerProtocol) {
        if cache[homeSceneId]?.manager != nil {
            anytypeAssertionFailure("Already cache")
        }
        
        cache[homeSceneId] = WeakValue(manager: manager)
    }
}
