import AnytypeCore
import Services
import ProtobufMessages

final class MentionMarkupEventProvider {
    
    @Injected(\.mentionTextUpdateHandler)
    private var mentionTextUpdateHandler: any MentionTextUpdateHandlerProtocol
    
    private let objectId: String
    private let infoContainer: any InfoContainerProtocol
    private let detailsStorage: ObjectDetailsStorage
        
    init(
        objectId: String,
        infoContainer: some InfoContainerProtocol,
        detailsStorage: ObjectDetailsStorage
    ) {
        self.objectId = objectId
        self.infoContainer = infoContainer
        self.detailsStorage = detailsStorage
    }
    
    func updateMentionsEvent() -> [DocumentUpdate] {
        mentionTextUpdateHandler.updateMentionsTextsIfNeeded(
            objectId: objectId,
            infoContainer: infoContainer,
            detailsStorage: detailsStorage
        ).map { .block(blockId: $0) }
    }
}
