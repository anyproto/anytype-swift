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
        
    // MARK: - Initializer
    
    init(
        document: BaseDocumentProtocol,
        fileService: FileActionsServiceProtocol,
        detailsService: DetailsServiceProtocol
    ) {
        self.document = document
        self.fileService = fileService
        self.detailsService = detailsService
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
    
    func removeCover() {
        Amplitude.instance().logEvent(AmplitudeEventsName.removeCover)
        detailsService.updateBundledDetails(
            [.coverType(CoverType.none), .coverId("")]
        )
    }
    
}
