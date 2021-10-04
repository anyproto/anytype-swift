import Combine
import UIKit
import BlocksModels
import Amplitude
import AnytypeCore

final class ObjectIconPickerViewModel: ObservableObject {
    
    let mediaPickerContentType: MediaPickerContentType = .images
    
    @Published var details: DetailsDataProtocol = DetailsData.empty
    var detailsLayout: DetailsLayout {
        details.layout ?? .basic
    }
    var isRemoveEnabled: Bool {
        switch detailsLayout {
        case .basic:
            return true
        case .profile:
            return !(details.iconImage?.isEmpty ?? true)
        default:
            anytypeAssertionFailure("`ObjectIconPickerViewModel` unavailable in \(detailsLayout)")
            return true
        }
    }

    // MARK: - Private variables
    
    private let imageUploadingDemon = FileUploadingDemon.shared
    private let fileService: BlockActionsServiceFile
    private let detailsService: ObjectDetailsService
    
    private var uploadImageSubscription: AnyCancellable?
    
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
                .iconEmoji: DetailsEntry(value: emojiUnicode),
                .iconImage: DetailsEntry(value: "")
            ]
        )
    }
    
    func uploadImage(from itemProvider: NSItemProvider) {
        // Analytics
        Amplitude.instance().logEvent(AmplitudeEventsName.buttonUploadPhoto)

        let operation = FileUploadingOperation(
            itemProvider: itemProvider,
            uploader: ObjectHeaderImageUploader()
        )
        operation.stateHandler = IconImageUploadingStateHandler(
            detailsService: detailsService
        )
        imageUploadingDemon.addOperation(operation)
    }
    
    func removeIcon() {
        // Analytics
        Amplitude.instance().logEvent(AmplitudeEventsName.buttonRemoveEmoji)
        
        detailsService.update(
            details: [
                .iconEmoji: DetailsEntry(value: ""),
                .iconImage: DetailsEntry(value: "")
            ]
        )
    }
    
}
