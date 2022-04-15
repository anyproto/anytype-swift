import Combine
import UIKit
import BlocksModels
import Amplitude
import AnytypeCore

final class ObjectIconPickerViewModel: ObservableObject, ObjectIconPickerViewModelProtocol {
    
    let mediaPickerContentType: MediaPickerContentType = .images

    var isRemoveButtonAvailable: Bool { document.details?.icon != nil }

    var detailsLayout: DetailsLayout {
        document.details?.layout ?? .basic
    }
    
    var isRemoveEnabled: Bool {
        switch detailsLayout {
        case .basic:
            return true
        case .profile:
            guard let details = document.details else { return false }
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
    
    private let document: BaseDocumentProtocol
    private let imageUploadingDemon = MediaFileUploadingDemon.shared
    private let fileService: FileActionsServiceProtocol
    private let detailsService: DetailsServiceProtocol
    
    private var subscription: AnyCancellable?
        
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
    
    private func setupSubscription() {
        subscription = document.updatePublisher.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
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
                objectId: document.objectId.value,
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
