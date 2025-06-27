import Foundation
import NotificationsCore
import SwiftUI
import Combine

protocol SpaceIconForNotificationsHandlerProtocol: AnyObject, Sendable {
    func startUpdating() async
    func stopUpdatingAndClearData() async
}

actor SpaceIconForNotificationsHandler: SpaceIconForNotificationsHandlerProtocol {
    
    @Injected(\.spaceIconStorage)
    private var spaceIconStorage: any SpaceIconStorageProtocol
    @Injected(\.workspaceStorage)
    private var workspacesStorage: any WorkspacesStorageProtocol
    
    private var workspaceSubscription: Task<Void, Never>?
    private var storage = [String: Icon]()
    
    func startUpdating() async {
        workspaceSubscription = Task { [weak self, workspacesStorage] in
            for await workspaces in workspacesStorage.allWorkspsacesPublisher.values {
                await self?.handleSpaces(workspaces: workspaces)
            }
        }
    }
    
    func stopUpdatingAndClearData() async {
        workspaceSubscription?.cancel()
        workspaceSubscription = nil
        spaceIconStorage.removeAll()
    }
    
    // MARK: - Private
    
    private func handleSpaces(workspaces: [SpaceView]) async {
        for space in workspaces {
            if let value = storage[space.targetSpaceId], value == space.objectIconImage {
                continue
            }
            
            let value = await Task { @MainActor in
                let spaceId = space.targetSpaceId
                let renderer = ImageRenderer(content: IconView(icon: space.objectIconImage).frame(width: 256, height: 256))
                if let cgImage = renderer.cgImage {
                    Task {
                        await saveIcon(spaceId: spaceId, icon: UIImage(cgImage: cgImage))
                    }
                }
                return space.objectIconImage
            }.value
            
            storage[space.targetSpaceId] = value
        }
    }
    
    private func saveIcon(spaceId: String, icon: UIImage) {
        spaceIconStorage.addIcon(spaceId: spaceId, icon: icon)
    }
}
