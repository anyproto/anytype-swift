import Foundation
import Services

@MainActor
final class ChatEmptyStateViewModel: ObservableObject {
    
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.documentService()
    
    private let document: any BaseDocumentProtocol
    private let onIconSelected: () -> Void
    private let onDone: () -> Void
    
    
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var icon: Icon?

    private var dataLoaded = false
    
    init(objectId: String, spaceId: String, onIconSelected: @escaping () -> Void, onDone: @escaping () -> Void) {
        self.document = openDocumentProvider.document(objectId: objectId, spaceId: spaceId)
        self.onIconSelected = onIconSelected
        self.onDone = onDone
    }
    
    func startDetailsSubscription() async {
        for await details in document.detailsPublisher.values {
            if !dataLoaded {
                title = details.name
                description = details.description
            }
            dataLoaded = true
            icon = details.objectIconImage
        }
    }
    
    func didTapIcon() {
        onIconSelected()
    }
    
    func titleUpdated() async throws {
        try await objectActionsService.updateBundledDetails(
            contextID: document.objectId,
            details: [.name(title)]
        )
    }
    
    func descriptionUpdated() async throws {
        try await objectActionsService.updateBundledDetails(
            contextID: document.objectId,
            details: [.description(description)]
        )
    }
    
    func didTapDone() {
        onDone()
    }
}
