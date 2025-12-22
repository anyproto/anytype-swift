import Foundation
import Services
import UniformTypeIdentifiers
import AnytypeCore

struct TextIconPickerData: Identifiable, Hashable {
    let contextId: String
    let objectId: String
    let spaceId: String

    var id: Int { hashValue }
}

@MainActor
@Observable
final class TextIconPickerViewModel {

    @ObservationIgnored @Injected(\.fileActionsService)
    private var fileService: any FileActionsServiceProtocol
    @ObservationIgnored @Injected(\.textServiceHandler)
    private var textServiceHandler: any TextServiceProtocol

    @ObservationIgnored
    private let contextId: String
    @ObservationIgnored
    private let objectId: String
    @ObservationIgnored
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

