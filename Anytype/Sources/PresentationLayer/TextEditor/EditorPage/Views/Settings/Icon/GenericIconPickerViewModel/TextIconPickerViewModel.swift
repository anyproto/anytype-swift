import Foundation
import Services
import UniformTypeIdentifiers
import Combine
import AnytypeCore

final class TextIconPickerViewModel: ObservableObject, ObjectIconPickerViewModelProtocol {
    let mediaPickerContentType: MediaPickerContentType = .images
    let isRemoveButtonAvailable: Bool = false

    private let fileService: FileActionsServiceProtocol
    private let textServiceHandler: TextServiceProtocol
    private let contextId: String
    private let objectId: String
    private let spaceId: String
    private var cancellables = [AnyCancellable]()

    init(
        fileService: FileActionsServiceProtocol,
        textServiceHandler: TextServiceProtocol,
        contextId: String,
        objectId: String,
        spaceId: String
    ) {
        self.fileService = fileService
        self.textServiceHandler = textServiceHandler
        self.contextId = contextId
        self.objectId = objectId
        self.spaceId = spaceId
    }
    

    func setEmoji(_ emojiUnicode: String)  {
        Task {
            try await textServiceHandler.setTextIcon(
                contextId: contextId,
                blockId: objectId,
                imageObjectId: "",
                emojiUnicode: emojiUnicode
            )
        }
    }

    func uploadImage(from itemProvider: NSItemProvider) {
        let safeSendableItemProvider = SafeSendable(value: itemProvider)
        Task {
            let fileDetails = try await fileService.uploadImage(spaceId: spaceId, source: .itemProvider(safeSendableItemProvider.value), origin: .none)
            try await textServiceHandler.setTextIcon(
                contextId: contextId,
                blockId: objectId,
                imageObjectId: fileDetails.id,
                emojiUnicode: ""
            )
        }
    }

    func removeIcon() { /* Unavailable */ }
}

