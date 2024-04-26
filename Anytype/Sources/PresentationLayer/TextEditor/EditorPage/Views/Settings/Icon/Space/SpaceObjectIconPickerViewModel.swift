import Combine
import UIKit
import Services
import AnytypeCore

@MainActor
final class SpaceObjectIconPickerViewModel: ObservableObject {

    // MARK: - Private variables
    
    private let spaceViewId: String
    
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    @Injected(\.fileActionsService)
    private var fileService: FileActionsServiceProtocol
    @Injected(\.documentService)
    private var openDocumentProvider: OpenedDocumentsProviderProtocol
    
    private lazy var document: BaseDocumentProtocol = {
        openDocumentProvider.document(objectId: spaceViewId, forPreview: false)
    }()
    
    @Published private(set) var isRemoveEnabled: Bool = false

    // MARK: - Initializer
    
    init(spaceViewId: String) {
        self.spaceViewId = spaceViewId
    }
    
    func startDocumentHandler() async {
        for await details in document.detailsPublisher.values {
            isRemoveEnabled = details.iconImage.isNotEmpty
        }
    }
    
    func uploadImage(from itemProvider: NSItemProvider) {
        guard let spaceId = document.details?.targetSpaceId else {
            anytypeAssertionFailure("target space id not found")
            return
        }
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setIcon)
        let safeSendableItemProvider = SafeSendable(value: itemProvider)
        Task {
            let data = try await fileService.createFileData(source: .itemProvider(safeSendableItemProvider.value))
            let fileDetails = try await fileService.uploadFileObject(spaceId: spaceId, data: data, origin: .none)
            try await workspaceService.workspaceSetDetails(spaceId: spaceId, details: [.iconObjectId(fileDetails.id)])
        }
    }
    
    func removeIcon() {
        guard let spaceId = document.details?.targetSpaceId else {
            anytypeAssertionFailure("target space id not found")
            return
        }
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.removeIcon)
        Task {
            try await workspaceService.workspaceSetDetails(spaceId: spaceId, details: [.iconObjectId("")])
        }
    }
}
