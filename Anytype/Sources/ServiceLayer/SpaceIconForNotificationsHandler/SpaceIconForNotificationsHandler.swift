import Foundation
import NotificationsCore
import SwiftUI
import Combine
import AnytypeCore

protocol SpaceIconForNotificationsHandlerProtocol: AnyObject, Sendable {
    func startUpdating() async
    func stopUpdatingAndClearData() async
}

actor SpaceIconForNotificationsHandler: SpaceIconForNotificationsHandlerProtocol {
    
    @Injected(\.spaceIconStorage)
    private var spaceIconStorage: any SpaceIconStorageProtocol
    @Injected(\.spaceViewsStorage)
    private var workspacesStorage: any SpaceViewsStorageProtocol
    
    @UserDefault("SpaceIcon.SavedItems", defaultValue: [:])
    private var savedIcons: [String: Int]
    
    private var workspaceSubscription: Task<Void, Never>?
    private var tasks = [String: Task<Void, Never>]()
    
    func startUpdating() async {
        workspaceSubscription = Task { [weak self, workspacesStorage] in
            for await workspaces in workspacesStorage.allSpaceViewsPublisher.values {
                await self?.handleSpaces(workspaces: workspaces)
            }
        }
    }
    
    func stopUpdatingAndClearData() async {
        workspaceSubscription?.cancel()
        workspaceSubscription = nil
        spaceIconStorage.removeAll()
        savedIcons.removeAll()
        tasks.removeAll()
    }
    
    // MARK: - Private
    
    private func handleSpaces(workspaces: [SpaceView]) async {
        for space in workspaces {
            
            guard savedIcons[space.targetSpaceId] != space.objectIconImage.hashValue, tasks[space.targetSpaceId].isNil else { continue }
            
            let task = Task { @MainActor [weak self] in
                let spaceId = space.targetSpaceId
                let renderer = ImageRenderer(content: IconView(icon: space.objectIconImage).frame(width: 256, height: 256))
                if let cgImage = renderer.cgImage {
                    Task {
                        await self?.saveIcon(spaceId: spaceId, icon: space.objectIconImage, image: UIImage(cgImage: cgImage))
                    }
                }
            }
            
            tasks[space.targetSpaceId] = task
        }
    }
    
    private func saveIcon(spaceId: String, icon: Icon, image: UIImage) {
        spaceIconStorage.addIcon(spaceId: spaceId, icon: image)
        savedIcons[spaceId] = icon.hashValue
        tasks.removeValue(forKey: spaceId)
    }
}
