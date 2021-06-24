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

extension DocumentCoverPickerViewModel {
    
    func setColor(_ colorName: String) {
        updateDetails(
            [
                .coverType: DetailsEntry(value: CoverType.color),
                .coverId: DetailsEntry(value: colorName)
            ]
        )
    }
    
    func setGradient(_ gradientName: String) {
        updateDetails(
            [
                .coverType: DetailsEntry(value: CoverType.gradient),
                .coverId: DetailsEntry(value: gradientName)
            ]
        )
    }
    
    func uploadImage(from itemProvider: NSItemProvider) {
        let supportedTypeIdentifiers = mediaPickerContentType.supportedTypeIdentifiers
        
        let typeIdentifier: String? = itemProvider.registeredTypeIdentifiers.first {
            supportedTypeIdentifiers.contains($0)
        }
        
        guard let typeIdentifier = typeIdentifier  else { return }
        
        itemProvider.loadFileRepresentation(
            forTypeIdentifier: typeIdentifier
        ) { [weak self] url, error in
            url.flatMap {
                self?.uploadImage(at: $0)
            }
        }
    }
    
    func removeCover() {
        updateDetails(
            [
                .coverType: DetailsEntry(value: CoverType.none),
                .coverId: DetailsEntry(value: "")
            ]
        )
    }
    
}

private extension DocumentCoverPickerViewModel {
    
    func uploadImage(at url: URL) {
        let localPath = url.relativePath
        
        NotificationCenter.default.post(
            name: .documentCoverImageUploadingEvent,
            object: localPath
        )
        
        uploadImageSubscription = fileService.uploadFile(
            url: "",
            localPath: localPath,
            type: .image,
            disableEncryption: false
        )
        .sinkWithDefaultCompletion("Cover upload image") { [weak self] uploadedImageHash in
            self?.updateDetails(
                [
                    .coverType: DetailsEntry(value: CoverType.uploadedImage),
                    .coverId: DetailsEntry(value: uploadedImageHash)
                ]
            )
        }
    }
    
    func updateDetails(_ details: [DetailsKind: DetailsEntry<AnyHashable>]) {
        updateDetailsSubscription = detailsActiveModel.update(
            details: details
        )?
        .sinkWithDefaultCompletion("Cover update details") { _ in }
    }
}
