import Foundation
import BlocksModels
import AnytypeCore

final class ObjectHeaderImageUploadingWorker {
    
    private var uploadedImageHash: Hash?
    
    private let fileService = BlockActionsServiceFile()
    private let detailsService: DetailsService
    private let usecase: ObjectHeaderImageUsecase
    
    init(detailsService: DetailsService, usecase: ObjectHeaderImageUsecase) {
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
        NotificationCenter.default.post(
            name: usecase.notificationName,
            object: ""
        )
    }
    
    func upload(_ localPath: String) {
        NotificationCenter.default.post(
            name: usecase.notificationName,
            object: localPath
        )
        uploadedImageHash = fileService.syncUploadImageAt(localPath: localPath)
    }
    
    func finish() {
        guard let hash = uploadedImageHash else { return }
        detailsService.updateBundledDetails(usecase.updatedDetails(with: hash))
    }
    
}
