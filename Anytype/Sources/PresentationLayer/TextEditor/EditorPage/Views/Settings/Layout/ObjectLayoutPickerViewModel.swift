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
    @Injected(\.openedDocumentProvider)
    private var openDocumentsProvider: any OpenedDocumentsProviderProtocol
    
    private let mode: ObjectLayoutPickerMode
    private let objectId: String
    private let spaceId: String
    private let analyticsType: AnalyticsObjectType
    
    private lazy var document: any BaseDocumentProtocol = {
        openDocumentsProvider.document(objectId: objectId, spaceId: spaceId)
    }()
    
    @Published var selectedLayout: DetailsLayout = .basic
    
    // MARK: - Initializer
    
    init(mode: ObjectLayoutPickerMode, objectId: String, spaceId: String, analyticsType: AnalyticsObjectType) {
        self.mode = mode
        self.objectId = objectId
        self.spaceId = spaceId
        self.analyticsType = analyticsType
    }
    
    func didSelectLayout(_ layout: DetailsLayout) {
        Task { @MainActor in
            switch mode {
            case .type:
                try await detailsService.updateBundledDetails(objectId: objectId, bundledDetails: [
                    .recommendedLayout(layout.rawValue)
                ])
                AnytypeAnalytics.instance().logChangeRecommendedLayout(objectType: analyticsType, layout: layout)
            case .object:
                try await detailsService.setLayout(objectId: objectId, detailsLayout: layout)
                AnytypeAnalytics.instance().logLayoutChange(layout)
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
                selectedLayout = details.resolvedLayoutValue
            }
        }
    }
}
