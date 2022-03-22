import Foundation
import BlocksModels
import AnytypeCore

final class ObjectHeaderImageUploadingWorker {
    
    private let objectId: BlockId
    private var uploadedImageHash: Hash?
    
    private let fileService = FileActionsService()
    private let detailsService: DetailsServiceProtocol
    private let usecase: ObjectHeaderImageUsecase
    
    init(
        objectId: BlockId,
        detailsService: DetailsServiceProtocol,
        usecase: ObjectHeaderImageUsecase
    ) {
        self.objectId = objectId
        self.detailsService = detailsService
        self.usecase = usecase
    }
    
}

extension ObjectHeaderImageUploadingWorker: MediaFileUploadingWorkerProtocol {
    
    var contentType: MediaPickerContentType {
        .images
    }

    func cancel() {
        #warning("Implement")
    }
    
    func prepare() {
        EventsBunch(
            contextId: objectId,
            localEvents: [
                usecase.localEvent(path: "")
            ]
        ).send()
    }
    
    func upload(_ localPath: String) {
        EventsBunch(
            contextId: objectId,
            localEvents: [
                usecase.localEvent(path: localPath)
            ]
        ).send()
        uploadedImageHash = fileService.syncUploadImageAt(localPath: localPath)
    }
    
    func finish() {
        guard let hash = uploadedImageHash else { return }
        detailsService.updateBundledDetails(usecase.updatedDetails(with: hash))
    }
    
}
