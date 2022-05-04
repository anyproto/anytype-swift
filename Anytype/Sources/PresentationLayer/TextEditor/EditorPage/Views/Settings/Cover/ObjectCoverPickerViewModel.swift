import Foundation
import BlocksModels
import Combine
import Amplitude

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
        Amplitude.instance().logEvent(AmplitudeEventsName.setCover)
        detailsService.updateBundledDetails(
            [.coverType(CoverType.color), .coverId(colorName)]
        )
    }
    
    func setGradient(_ gradientName: String) {
        Amplitude.instance().logEvent(AmplitudeEventsName.setCover)
        detailsService.updateBundledDetails(
            [.coverType(CoverType.gradient), .coverId(gradientName)]
        )
    }

    func setUnsplash(_ imageId: String) {
        Amplitude.instance().logEvent(AmplitudeEventsName.setCover)
        detailsService.updateBundledDetails(
            ObjectHeaderImageUsecase.cover.updatedDetails(with: .init(imageId)!)
        )
    }
    
    
    func uploadImage(from itemProvider: NSItemProvider) {
        Amplitude.instance().logEvent(AmplitudeEventsName.setCover)
        let operation = MediaFileUploadingOperation(
            itemProvider: itemProvider,
            worker: ObjectHeaderImageUploadingWorker(
                objectId: document.objectId,
                detailsService: detailsService,
                usecase: .cover
            )
        )
        imageUploadingDemon.addOperation(operation)
    }

    func uploadUnplashCover(unsplashItem: UnsplashItem) {
        Amplitude.instance().logEvent(AmplitudeEventsName.setCover)
        EventsBunch(
            contextId: document.objectId,
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
        Amplitude.instance().logEvent(AmplitudeEventsName.removeCover)
        detailsService.updateBundledDetails(
            [.coverType(CoverType.none), .coverId("")]
        )
    }
    
}
