import Foundation
import Services
import Combine
import SwiftUI

@MainActor
final class ObjectLayoutPickerViewModel: ObservableObject {

    // MARK: - Private variables
    
    @Injected(\.detailsService)
    private var detailsService: any DetailsServiceProtocol
    @Injected(\.documentService)
    private var openDocumentsProvider: any OpenedDocumentsProviderProtocol
    
    private let objectId: String
    private let spaceId: String
    
    private lazy var document: any BaseDocumentProtocol = {
        openDocumentsProvider.document(objectId: objectId, spaceId: spaceId)
    }()
    
    @Published var selectedLayout: DetailsLayout = .basic
    
    // MARK: - Initializer
    
    init(objectId: String, spaceId: String) {
        self.objectId = objectId
        self.spaceId = spaceId
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
