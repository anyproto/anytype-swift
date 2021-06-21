import Combine
import UIKit
import BlocksModels

final class DocumentCoverPickerViewModel: ObservableObject {
    
    let mediaPickerContentType: MediaPickerContentType = .images

    // MARK: - Private variables
    
    private let fileService: BlockActionsServiceFile
    private let detailsActiveModel: DetailsActiveModel
    
    private var uploadImageSubscription: AnyCancellable?
    private var updateDetailsSubscription: AnyCancellable?
    
    // MARK: - Initializer
    
    init(fileService: BlockActionsServiceFile, detailsActiveModel: DetailsActiveModel) {
        self.fileService = fileService
        self.detailsActiveModel = detailsActiveModel
    }
    
}
