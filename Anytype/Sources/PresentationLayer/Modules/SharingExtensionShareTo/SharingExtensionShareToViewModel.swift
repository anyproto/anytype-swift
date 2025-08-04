import SwiftUI

@MainActor
final class SharingExtensionShareToViewModel: ObservableObject {
    
    @Injected(\.workspaceStorage)
    private var workspacesStorage: any WorkspacesStorageProtocol
    
    private let data: SharingExtensionShareToData
    
    @Published var title: String = ""
    @Published var searchText: String = ""
    
    init(data: SharingExtensionShareToData) {
        self.data = data
        self.title = workspacesStorage.spaceView(spaceId: data.spaceId)?.title ?? ""
    }
    
    func search() async throws {
        
    }
}
