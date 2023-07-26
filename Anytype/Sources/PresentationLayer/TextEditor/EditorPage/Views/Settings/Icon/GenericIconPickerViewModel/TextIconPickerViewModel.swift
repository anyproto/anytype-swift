import Foundation
import Services
import UniformTypeIdentifiers
import Combine

final class TextIconPickerViewModel: ObjectIconPickerViewModelProtocol {
    let mediaPickerContentType: MediaPickerContentType = .images
    let isRemoveButtonAvailable: Bool = false

    private let fileService: FileActionsServiceProtocol
    private let textService: TextServiceProtocol
    private let contextId: BlockId
    private let objectId: BlockId
    private let spaceId: String
    private var cancellables = [AnyCancellable]()

    init(
        fileService: FileActionsServiceProtocol,
        textService: TextServiceProtocol,
        contextId: BlockId,
        objectId: BlockId,
        spaceId: String
    ) {
        self.fileService = fileService
        self.textService = textService
        self.contextId = contextId
        self.objectId = objectId
        self.spaceId = spaceId
    }
    

    func setEmoji(_ emojiUnicode: String)  {
        Task {
            try await textService.setTextIcon(
                contextId: contextId,
                blockId: objectId,
                imageHash: "",
                emojiUnicode: emojiUnicode
            )
        }
    }

    func uploadImage(from itemProvider: NSItemProvider) {
        Task {
            let hash = try await fileService.uploadImage(spaceId: spaceId, source: .itemProvider(itemProvider))
            try await textService.setTextIcon(
                contextId: contextId,
                blockId: objectId,
                imageHash: hash.value,
                emojiUnicode: ""
            )
        }
    }

    func removeIcon() { /* Unavailable */ }
}

