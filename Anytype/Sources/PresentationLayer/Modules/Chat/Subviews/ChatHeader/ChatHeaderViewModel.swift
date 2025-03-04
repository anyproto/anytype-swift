import Foundation
import SwiftUI

@MainActor
final class ChatHeaderViewModel: ObservableObject {
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    
    @Published private(set) var title: String?
    @Published private(set) var icon: Icon?
    
    private let spaceId: String
    private let onTapOpenWidgets: () -> Void
    
    init(spaceId: String, onTapOpenWidgets: @escaping () -> Void) {
        self.spaceId = spaceId
        self.onTapOpenWidgets = onTapOpenWidgets
    }
    
    func subscribe() async {
        for await spaceInfo in workspaceStorage.spaceViewPublisher(spaceId: spaceId).values {
            title = spaceInfo.title
            icon = spaceInfo.objectIconImage
        }
    }
    
    func tapOpenWidgets() {
        onTapOpenWidgets()
    }
}
