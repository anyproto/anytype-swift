import Foundation
import Services

@MainActor
final class DiscussionEmptyStateViewModel: ObservableObject {
    
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var icon: Icon?
    
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.documentService()
    
    private let document: any BaseDocumentProtocol
    private let onIconSelected: () -> Void
    private let onDone: () -> Void
    
    init(objectId: String, onIconSelected: @escaping () -> Void, onDone: @escaping () -> Void) {
        self.document = openDocumentProvider.document(objectId: objectId)
        self.onIconSelected = onIconSelected
        self.onDone = onDone
    }
    
    func startDetailsSubscription() async {
        for await details in document.detailsPublisher.values {
            title = details.name
            description = details.description
            icon = details.objectIconImageWithPlaceholder
        }
    }
    
    func didTapIcon() {
        onIconSelected()
    }
    
    func titleUpdated() {
        Task {
            try await objectActionsService.updateBundledDetails(
                contextID: document.objectId,
                details: [.name(title)]
            )
        }
    }
    
    func descriptionUpdated() {
        Task {
            try await objectActionsService.updateBundledDetails(
                contextID: document.objectId,
                details: [.description(description)]
            )
        }
    }
    
    func didTapDone() {
        onDone()
    }
}
