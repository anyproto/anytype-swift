import Foundation
import Services
import Combine
import SwiftUI

enum ObjectLayoutPickerMode {
    case type
    case object
}

@MainActor
final class ObjectLayoutPickerViewModel: ObservableObject {

    // MARK: - Private variables
    
    @Injected(\.detailsService)
    private var detailsService: any DetailsServiceProtocol
    @Injected(\.documentService)
    private var openDocumentsProvider: any OpenedDocumentsProviderProtocol
    
    private let mode: ObjectLayoutPickerMode
    private let objectId: String
    private let spaceId: String
    
    private lazy var document: any BaseDocumentProtocol = {
        openDocumentsProvider.document(objectId: objectId, spaceId: spaceId)
    }()
    
    @Published var selectedLayout: DetailsLayout = .basic
    
    // MARK: - Initializer
    
    init(mode: ObjectLayoutPickerMode, objectId: String, spaceId: String) {
        self.mode = mode
        self.objectId = objectId
        self.spaceId = spaceId
    }
    
    func didSelectLayout(_ layout: DetailsLayout) {
        AnytypeAnalytics.instance().logLayoutChange(layout)
        Task { @MainActor in
            switch mode {
            case .type:
                try await detailsService.updateBundledDetails(objectId: objectId, bundledDetails: [
                    .recommendedLayout(layout.rawValue)
                ])
            case .object:
                try await detailsService.setLayout(objectId: objectId, detailsLayout: layout)
            }
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    func startDocumentSubscription() async {
        for await details in document.detailsPublisher.values {
            switch mode {
            case .type:
                selectedLayout = details.recommendedLayoutValue ?? .basic
            case .object:
                selectedLayout = details.layoutValue
            }
        }
    }
}
