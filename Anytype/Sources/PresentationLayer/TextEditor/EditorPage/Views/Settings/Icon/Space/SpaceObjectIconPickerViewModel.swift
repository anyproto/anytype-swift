import Combine
import UIKit
import Services
import AnytypeCore

@MainActor
final class SpaceObjectIconPickerViewModel: ObservableObject {

    // MARK: - Private variables
    
    private let spaceId: String
    
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.fileActionsService)
    private var fileService: any FileActionsServiceProtocol
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    
    @Published private(set) var isRemoveEnabled: Bool = false

    // MARK: - Initializer
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    func startSpaceTask() async {
        for await space in workspaceStorage.spaceViewPublisher(spaceId: spaceId).values {
            isRemoveEnabled = space.objectIconImage.imageId.isNotNil ?? false
        }
    }
    
    func uploadImage(from itemProvider: NSItemProvider) {
        AnytypeAnalytics.instance().logSetIcon()
        let safeSendableItemProvider = itemProvider.sendable()
        Task {
            let data = try await fileService.createFileData(source: .itemProvider(safeSendableItemProvider.value))
            let fileDetails = try await fileService.uploadFileObject(spaceId: spaceId, data: data, origin: .none)
            try await workspaceService.workspaceSetDetails(spaceId: spaceId, details: [.iconObjectId(fileDetails.id)])
        }
    }
    
    func removeIcon() {
        AnytypeAnalytics.instance().logRemoveIcon()
        Task {
            try await workspaceService.workspaceSetDetails(spaceId: spaceId, details: [.iconObjectId("")])
        }
    }
}
