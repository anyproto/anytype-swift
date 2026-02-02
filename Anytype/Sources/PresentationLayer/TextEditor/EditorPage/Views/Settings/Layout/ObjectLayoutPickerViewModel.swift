import Foundation
import Services
import SwiftUI

enum ObjectLayoutPickerMode {
    case type
    case object
}

@MainActor
@Observable
final class ObjectLayoutPickerViewModel {

    // MARK: - Private variables

    @ObservationIgnored @Injected(\.detailsService)
    private var detailsService: any DetailsServiceProtocol
    @ObservationIgnored @Injected(\.openedDocumentProvider)
    private var openDocumentsProvider: any OpenedDocumentsProviderProtocol

    @ObservationIgnored
    private let mode: ObjectLayoutPickerMode
    @ObservationIgnored
    private let objectId: String
    @ObservationIgnored
    private let spaceId: String
    @ObservationIgnored
    private let analyticsType: AnalyticsObjectType

    @ObservationIgnored
    private lazy var document: any BaseDocumentProtocol = {
        openDocumentsProvider.document(objectId: objectId, spaceId: spaceId)
    }()

    var selectedLayout: DetailsLayout = .basic
    
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
