import SwiftUI
import Factory
import Services

@MainActor
@Observable
final class SpaceTypeChangeViewModel {

    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var workspaceStorage: any SpaceViewsStorageProtocol
    @ObservationIgnored
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol

    private let data: SpaceTypeChangeData
    private var expectedSpaceType: SpaceUxType?

    var chatIsSelected: Bool = false
    var dataIsSelected: Bool = false
    var showAlert: Bool = false

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
        expectedSpaceType = .chat
        showAlert = true
    }
    
    func onTapData() async throws {
        guard !dataIsSelected else { return }
        expectedSpaceType = .data
        showAlert = true
    }
    
    func onChange() async throws {
        guard let expectedSpaceType else { return }
        try await workspaceService.workspaceSetDetails(spaceId: data.spaceId, details: [.spaceUxType(expectedSpaceType)])
    }
}
