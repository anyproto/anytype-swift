import Foundation
import Services
import Combine
import SwiftUI

@MainActor
final class ObjectLayoutPickerViewModel: ObservableObject {

    // MARK: - Private variables
    
    @Injected(\.detailsService)
    private var detailsService: DetailsServiceProtocol
    @Injected(\.documentService)
    private var openDocumentsProvider: OpenedDocumentsProviderProtocol
    
    private let objectId: String
    
    private lazy var document: BaseDocumentProtocol = {
        openDocumentsProvider.document(objectId: objectId)
    }()
    
    @Published var selectedLayout: DetailsLayout = .basic
    
    // MARK: - Initializer
    
    init(objectId: String) {
        self.objectId = objectId
    }
    
    func didSelectLayout(_ layout: DetailsLayout) {
        AnytypeAnalytics.instance().logLayoutChange(layout)
        Task { @MainActor in
            try await detailsService.setLayout(objectId: objectId, detailsLayout: layout)
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    func startDocumentSubscription() async {
        for await details in document.detailsPublisher.values {
            selectedLayout = details.layoutValue
        }
    }
}
