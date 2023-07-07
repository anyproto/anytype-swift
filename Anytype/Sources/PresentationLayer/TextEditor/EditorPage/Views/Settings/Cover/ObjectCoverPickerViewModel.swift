import Foundation
import Services
import Combine

final class ObjectCoverPickerViewModel: ObservableObject {
    
    let mediaPickerContentType: MediaPickerContentType = .images

    var isRemoveButtonAvailable: Bool { document.details?.documentCover != nil }

    // MARK: - Private variables
    private let document: BaseDocumentGeneralProtocol
    private let objectId: String
    private let fileService: FileActionsServiceProtocol
    private let detailsService: DetailsServiceProtocol
    private let unsplashService: UnsplashServiceProtocol
        
    // MARK: - Initializer
    
    init(
        document: BaseDocumentGeneralProtocol,
        objectId: String,
        fileService: FileActionsServiceProtocol,
        detailsService: DetailsServiceProtocol,
        unsplashService: UnsplashServiceProtocol = UnsplashService()
    ) {
        self.document = document
        self.objectId = objectId
        self.fileService = fileService
        self.detailsService = detailsService
        self.unsplashService = unsplashService
    }
}

extension ObjectCoverPickerViewModel {
    
    func setColor(_ colorName: String) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setCover)
        Task {
            try? await detailsService.updateBundledDetails(
                [.coverType(CoverType.color), .coverId(colorName)]
            )
        }
    }
    
    func setGradient(_ gradientName: String) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setCover)
        Task {
            try? await detailsService.updateBundledDetails(
                [.coverType(CoverType.gradient), .coverId(gradientName)]
            )
        }
    }
    
    func uploadImage(from itemProvider: NSItemProvider) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setCover)
        Task {
            try await detailsService.setCover(source: .itemProvider(itemProvider))
        }
    }

    func uploadUnplashCover(unsplashItem: UnsplashItem) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setCover)
        EventsBunch(
            contextId: objectId,
            localEvents: [unsplashItem.updateEvent]
        ).send()

        Task { @MainActor in
            let imageHash = try await unsplashService.downloadImage(id: unsplashItem.id)
            try await detailsService.setCover(imageHash: imageHash)
        }
    }
    
    func removeCover() {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.removeCover)
        Task {
            try? await detailsService.updateBundledDetails(
                [.coverType(CoverType.none), .coverId("")]
            )
        }
    }
}
