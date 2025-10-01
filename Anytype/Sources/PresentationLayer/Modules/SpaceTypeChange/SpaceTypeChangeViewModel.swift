import SwiftUI
import Factory
import Services

@MainActor
final class SpaceTypeChangeViewModel: ObservableObject {
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    
    private let data: SpaceTypeChangeData
    
    @Published var chatIsSelected: Bool = false
    @Published var dataIsSelected: Bool = false
    
    init(data: SpaceTypeChangeData) {
        self.data = data
    }
    
    func startSubscriptions() async {
        for await spaceType in workspaceStorage.spaceViewPublisher(spaceId: data.spaceId).map(\.uxType).removeDuplicates().values {
            chatIsSelected = spaceType.isChat
            dataIsSelected = spaceType.isData
        }
    }
    
    func onTapChat() async throws {
        guard !chatIsSelected else { return }
        try await workspaceService.workspaceSetDetails(spaceId: data.spaceId, details: [.spaceUxType(.chat)])
    }
    
    func onTapData() async throws {
        guard !dataIsSelected else { return }
        try await workspaceService.workspaceSetDetails(spaceId: data.spaceId, details: [.spaceUxType(.data)])
    }
}
