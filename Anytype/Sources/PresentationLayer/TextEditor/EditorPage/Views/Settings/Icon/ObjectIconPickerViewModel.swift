import Combine
import UIKit
import BlocksModels
import Amplitude
import AnytypeCore

final class ObjectIconPickerViewModel: ObservableObject {
    
    let mediaPickerContentType: MediaPickerContentType = .images
    
    @Published var details: ObjectDetails = ObjectDetails([])
    var detailsLayout: DetailsLayout {
        details.layout
    }
    var isRemoveEnabled: Bool {
        switch detailsLayout {
        case .basic:
            return true
        case .profile:
            return details.iconImageHash.isNotNil
        default:
            anytypeAssertionFailure("`ObjectIconPickerViewModel` unavailable in \(detailsLayout)")
            return true
        }
    }

    // MARK: - Private variables
    
    private let imageUploadingDemon = MediaFileUploadingDemon.shared
    private let fileService: BlockActionsServiceFile
    private let detailsService: ObjectDetailsService
        
    // MARK: - Initializer
    
    init(fileService: BlockActionsServiceFile, detailsService: ObjectDetailsService) {
        self.fileService = fileService
        self.detailsService = detailsService
    }
    
}

extension ObjectIconPickerViewModel {
    func setEmoji(_ emojiUnicode: String) {
        detailsService.update(
            details: [
                .iconEmoji(emojiUnicode), .iconImageHash(nil)
            ]
        )
    }
    
    func uploadImage(from itemProvider: NSItemProvider) {
        // Analytics
        Amplitude.instance().logEvent(AmplitudeEventsName.buttonUploadPhoto)

        let operation = MediaFileUploadingOperation(
            itemProvider: itemProvider,
            worker: ObjectHeaderImageUploadingWorker(
                detailsService: detailsService,
                usecase: .icon
            )
        )
        imageUploadingDemon.addOperation(operation)
    }
    
    func removeIcon() {
        // Analytics
        Amplitude.instance().logEvent(AmplitudeEventsName.buttonRemoveEmoji)
        
        detailsService.update(
            details: [.iconEmoji(""), .iconImageHash(nil)]
        )
    }
    
}
