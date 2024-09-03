import Foundation
import SwiftUI
import AnytypeCore

protocol SpaceSetupManagerProtocol :AnyObject {
    func setActiveSpace(sceneId: String, spaceId: String) async throws
    func registerSpaceSetter(sceneId: String, setter: any ActiveSpaceSetterProtocol) async
}

actor SpaceSetupManager: SpaceSetupManagerProtocol {
    
    private struct WeakValue {
        weak var setter: (any ActiveSpaceSetterProtocol)?
    }
    
    private var cache: [String: WeakValue] = [:]
    
    // MARK: - SpaceSetupManagerProtocol
    
    func setActiveSpace(sceneId: String, spaceId: String) async throws {
        guard let setter = cache[sceneId]?.setter else {
            anytypeAssertionFailure("Manager not found")
            return
        }
        try await setter.setActiveSpace(spaceId: spaceId)
    }
    
    func registerSpaceSetter(sceneId: String, setter: any ActiveSpaceSetterProtocol) {
        if cache[sceneId]?.setter != nil {
            anytypeAssertionFailure("Already cache")
        }
        
        cache[sceneId] = WeakValue(setter: setter)
    }
}
