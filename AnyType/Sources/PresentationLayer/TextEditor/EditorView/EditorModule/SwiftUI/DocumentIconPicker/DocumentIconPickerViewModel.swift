import Combine
import UIKit
import BlocksModels

final class DocumentIconPickerViewModel: ObservableObject {
    
    // MARK: - Private variables
    
    private let fileService: BlockActionsServiceFile
    private let detailsActiveModel: DetailsActiveModel
    
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    
    init(fileService: BlockActionsServiceFile, detailsActiveModel: DetailsActiveModel) {
        self.fileService = fileService
        self.detailsActiveModel = detailsActiveModel
    }
    
}

extension DocumentIconPickerViewModel {
    
    func setEmoji(_ emojiUnicode: String) {
        updateDetails(
            [
                .iconEmoji: DetailsEntry(value: emojiUnicode),
                .iconImage: DetailsEntry(value: "")
            ]
        )
    }
    
    func uploadImage(at url: URL) {
        fileService.uploadFile(
            url: "",
            localPath: url.relativePath,
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
        .store(in: &self.subscriptions)
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

private extension DocumentIconPickerViewModel {
    
    func updateDetails(_ details: [DetailsKind: DetailsEntry<AnyHashable>]) {
        detailsActiveModel.update(
            details: details
        )?
        .sinkWithDefaultCompletion("Emoji setDetails remove icon emoji") { _ in }
        .store(in: &subscriptions)
    }
    
}

