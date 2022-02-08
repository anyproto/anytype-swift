import Combine
import UIKit
import BlocksModels
import Amplitude
import AnytypeCore

final class ObjectIconPickerViewModel: ObservableObject {
    
    let mediaPickerContentType: MediaPickerContentType = .images
    
    @Published var details: ObjectDetails = ObjectDetails(id: "", values: [:])
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
            anytypeAssertionFailure(
                "`ObjectIconPickerViewModel` unavailable in \(detailsLayout)",
                domain: .iconPicker
            )
            return true
        }
    }

    // MARK: - Private variables
    
    private let imageUploadingDemon = MediaFileUploadingDemon.shared
    private let fileService: BlockActionsServiceFile
    private let detailsService: DetailsService
        
    // MARK: - Initializer
    
    init(fileService: BlockActionsServiceFile, detailsService: DetailsService) {
        self.fileService = fileService
        self.detailsService = detailsService
    }
    
}

extension ObjectIconPickerViewModel {
    func setEmoji(_ emojiUnicode: String) {
        Amplitude.instance().logEvent(AmplitudeEventsName.setIcon)
        detailsService.updateBundledDetails([.iconEmoji(emojiUnicode), .iconImageHash(nil)])
    }
    
    func uploadImage(from itemProvider: NSItemProvider) {
        Amplitude.instance().logEvent(AmplitudeEventsName.setIcon)

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
        Amplitude.instance().logEvent(AmplitudeEventsName.removeIcon)
        
        detailsService.updateBundledDetails(
            [.iconEmoji(""), .iconImageHash(nil)]
        )
    }
    
}
