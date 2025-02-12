import Foundation
import Services
import UniformTypeIdentifiers
import Combine
import AnytypeCore

struct TextIconPickerData: Identifiable, Hashable {
    let contextId: String
    let objectId: String
    let spaceId: String
    
    var id: Int { hashValue }
}

@MainActor
final class TextIconPickerViewModel: ObservableObject {
    
    @Injected(\.fileActionsService)
    private var fileService: any FileActionsServiceProtocol
    @Injected(\.textServiceHandler)
    private var textServiceHandler: any TextServiceProtocol
    
    private let contextId: String
    private let objectId: String
    private let spaceId: String

    init(data: TextIconPickerData) {
        self.contextId = data.contextId
        self.objectId = data.objectId
        self.spaceId = data.spaceId
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
        let safeSendableItemProvider = itemProvider.sendable()
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
}

