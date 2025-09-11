import Foundation
import Services
import Factory

struct AttachmentValidationResult {
    let canAdd: Bool
    let remainingCount: Int
    let maxCount: Int
    
    var error: AttachmentError? {
        canAdd ? nil : .fileLimitExceeded
    }
}

@MainActor
struct ChatAttachmentValidator {
    
    @Injected(\.chatMessageLimits)
    private var chatMessageLimits: any ChatMessageLimitsProtocol
    
    nonisolated init() { }
    
    func validateSingleAttachment(currentCount: Int) -> AttachmentValidationResult {
        let canAdd = chatMessageLimits.oneAttachmentCanBeAdded(current: currentCount)
        let remainingCount = chatMessageLimits.countAttachmentsCanBeAdded(current: currentCount)
        return AttachmentValidationResult(
            canAdd: canAdd,
            remainingCount: remainingCount,
            maxCount: currentCount + remainingCount
        )
    }
    
    func validateMultipleAttachments(currentCount: Int, addingCount: Int) -> AttachmentValidationResult {
        let availableCount = chatMessageLimits.countAttachmentsCanBeAdded(current: currentCount)
        let canAdd = addingCount <= availableCount
        return AttachmentValidationResult(
            canAdd: canAdd,
            remainingCount: availableCount,
            maxCount: currentCount + availableCount
        )
    }
}

extension Container {
    var chatAttachmentValidator: Factory<ChatAttachmentValidator> {
        self { ChatAttachmentValidator() }.shared
    }
}
