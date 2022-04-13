import Foundation
import BlocksModels
import UniformTypeIdentifiers
import Combine

final class TextIconPickerViewModel: ObjectIconPickerViewModelProtocol {
    let mediaPickerContentType: MediaPickerContentType = .images
    let isRemoveButtonAvailable: Bool = false

    private let fileService: FileActionsServiceProtocol
    private let textService: TextServiceProtocol
    private let contextId: BlockId
    private let objectId: BlockId
    private var cancellables = [AnyCancellable]()

    init(
        fileService: FileActionsServiceProtocol,
        textService: TextServiceProtocol,
        contextId: BlockId,
        objectId: BlockId
    ) {
        self.fileService = fileService
        self.textService = textService
        self.contextId = contextId
        self.objectId = objectId
    }
    

    func setEmoji(_ emojiUnicode: String) {
        textService.setTextIcon(
            contextId: contextId,
            blockId: objectId,
            imageHash: "",
            emojiUnicode: emojiUnicode
        )
    }

    func uploadImage(from itemProvider: NSItemProvider) {
        let typeIdentifier: String = itemProvider.registeredTypeIdentifiers.first {
            MediaPickerContentType.images.supportedTypeIdentifiers.contains($0)
        } ?? ""

        itemProvider.loadFileRepresentation(
            forTypeIdentifier: typeIdentifier
        ) { [self] localPath, error in
            guard let localPath = localPath else {
                return
            }
            uploadImage(from: localPath)
        }
    }

    func removeIcon() { /* Unavailable */ }

    private func uploadImage(from url: URL) {
        fileService
            .asyncUploadImage(at: url)
            .sinkWithResult { [self] result in
                switch result {
                case .success(let hash):
                    guard let hash = hash else { return }
                    textService.setTextIcon(
                        contextId: contextId,
                        blockId: objectId,
                        imageHash: hash.value,
                        emojiUnicode: ""
                    )
                case .failure: break
                }
            }.store(in: &self.cancellables)
    }
}

