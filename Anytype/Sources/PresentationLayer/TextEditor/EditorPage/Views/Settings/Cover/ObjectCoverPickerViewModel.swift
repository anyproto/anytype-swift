import Foundation
import BlocksModels
import Combine

final class ObjectCoverPickerViewModel: ObservableObject {
    
    let mediaPickerContentType: MediaPickerContentType = .images

    var isRemoveButtonAvailable: Bool { document.details?.documentCover != nil }

    // MARK: - Private variables
    private let document: BaseDocumentProtocol
    private let imageUploadingDemon = MediaFileUploadingDemon.shared
    private let fileService: FileActionsServiceProtocol
    private let detailsService: DetailsServiceProtocol
    private let unsplashDownloadService: UnslpashItemDownloader

    private var cancellables = [AnyCancellable]()
        
    // MARK: - Initializer
    
    init(
        document: BaseDocumentProtocol,
        fileService: FileActionsServiceProtocol,
        detailsService: DetailsServiceProtocol,
        unsplashDownloadService: UnslpashItemDownloader = UnsplashService()
    ) {
        self.document = document
        self.fileService = fileService
        self.detailsService = detailsService
        self.unsplashDownloadService = unsplashDownloadService
    }
}

extension ObjectCoverPickerViewModel {
    
    func setColor(_ colorName: String) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setCover)
        detailsService.updateBundledDetails(
            [.coverType(CoverType.color), .coverId(colorName)]
        )
    }
    
    func setGradient(_ gradientName: String) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setCover)
        detailsService.updateBundledDetails(
            [.coverType(CoverType.gradient), .coverId(gradientName)]
        )
    }

    func setUnsplash(_ imageId: String) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setCover)
        detailsService.updateBundledDetails(
            ObjectHeaderImageUsecase.cover.updatedDetails(with: .init(imageId)!)
        )
    }
    
    
    func uploadImage(from itemProvider: NSItemProvider) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setCover)
        let operation = MediaFileUploadingOperation(
            itemProvider: itemProvider,
            worker: ObjectHeaderImageUploadingWorker(
                objectId: document.objectId.value,
                detailsService: detailsService,
                usecase: .cover
            )
        )
        imageUploadingDemon.addOperation(operation)
    }

    func uploadUnplashCover(unsplashItem: UnsplashItem) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setCover)
        EventsBunch(
            contextId: document.objectId.value,
            localEvents: [unsplashItem.updateEvent]
        ).send()

        unsplashDownloadService
            .downloadImage(id: unsplashItem.id)
            .receiveOnMain()
            .sinkWithResult { result in
                let imageHash = result.getValue(domain: .unsplash)
                imageHash.map(self.setUnsplash)
            }.store(in: &cancellables)
    }
    
    func removeCover() {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.removeCover)
        detailsService.updateBundledDetails(
            [.coverType(CoverType.none), .coverId("")]
        )
    }
    
}
