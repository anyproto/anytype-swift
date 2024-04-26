import Foundation

final class ObjectIconActionHandler: ObjectIconActionHandlerProtocol {
    
    @Injected(\.objectHeaderUploadingService)
    private var objectHeaderUploadingService: ObjectHeaderUploadingServiceProtocol
    
    func handleIconAction(document: BaseDocumentGeneralProtocol, action: ObjectIconPickerAction) {
        Task {
            try await objectHeaderUploadingService.handleIconAction(
                objectId: document.objectId,
                spaceId: document.spaceId,
                action: action
            )
        }
    }
}
