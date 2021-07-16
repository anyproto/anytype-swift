import Combine
import UIKit
import BlocksModels

final class ObjectIconPickerViewModel: ObservableObject {
    
    let mediaPickerContentType: MediaPickerContentType = .images

    @Published private(set) var detailsLayout: DetailsLayout = .basic
    @Published private(set) var isRemoveEnabled = true

    // MARK: - Private variables
    
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
    
    func update(with details: DetailsData) {
        detailsLayout = details.layout ?? .basic
     
        isRemoveEnabled = {
            switch detailsLayout {
            case .basic:
                return true
            case .profile:
                return !(details.iconImage?.isEmpty ?? true)
            }
        }()
    }
    
    func setEmoji(_ emojiUnicode: String) {
        detailsService.update(
            details: [
                .iconEmoji: DetailsEntry(value: emojiUnicode),
                .iconImage: DetailsEntry(value: "")
            ]
        )
    }
    
    func uploadImage(from itemProvider: NSItemProvider) {
        let supportedTypeIdentifiers = mediaPickerContentType.supportedTypeIdentifiers
        
        let typeIdentifier: String? = itemProvider.registeredTypeIdentifiers.first {
            supportedTypeIdentifiers.contains($0)
        }
        
        guard let identifier = typeIdentifier  else { return }
        
        itemProvider.loadFileRepresentation(
            forTypeIdentifier: identifier
        ) { [weak self] url, error in
            url.flatMap {
                self?.uploadImage(at: $0)
            }
        }
    }
    
    func removeIcon() {
        detailsService.update(
            details: [
                .iconEmoji: DetailsEntry(value: ""),
                .iconImage: DetailsEntry(value: "")
            ]
        )
    }
    
}

private extension ObjectIconPickerViewModel {
    
    func uploadImage(at url: URL) {
        let localPath = url.relativePath
        
        NotificationCenter.default.post(
            name: .documentIconImageUploadingEvent,
            object: localPath
        )
        
        uploadImageSubscription = fileService.uploadFile(
            url: "",
            localPath: localPath,
            type: .image,
            disableEncryption: false
        )
        .sinkWithDefaultCompletion("Emoji uploadImage upload image") { [weak self] uploadedImageHash in
            self?.detailsService.update(
                details: [
                    .iconEmoji: DetailsEntry(value: ""),
                    .iconImage: DetailsEntry(value: uploadedImageHash)
                ]
            )
        }
    }
    
}
