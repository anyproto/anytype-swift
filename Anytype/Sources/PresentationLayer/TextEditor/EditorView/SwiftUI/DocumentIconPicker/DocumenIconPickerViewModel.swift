import Combine
import UIKit
import BlocksModels

final class DocumenIconPickerViewModel: ObservableObject {
    
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

extension DocumenIconPickerViewModel {
    
    func setEmoji(_ emojiUnicode: String) {
        updateDetails(
            [
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
        updateDetails(
            [
                .iconEmoji: DetailsEntry(value: ""),
                .iconImage: DetailsEntry(value: "")
            ]
        )
    }
    
}

private extension DocumenIconPickerViewModel {
    
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
            self?.updateDetails(
                [
                    .iconEmoji: DetailsEntry(value: ""),
                    .iconImage: DetailsEntry(value: uploadedImageHash)
                ]
            )
        }
    }
    
    func updateDetails(_ details: [DetailsKind: DetailsEntry<AnyHashable>]) {
        updateDetailsSubscription = detailsActiveModel.update(
            details: details
        )?
        .sinkWithDefaultCompletion("Emoji setDetails remove icon emoji") { _ in }
    }
    
}
