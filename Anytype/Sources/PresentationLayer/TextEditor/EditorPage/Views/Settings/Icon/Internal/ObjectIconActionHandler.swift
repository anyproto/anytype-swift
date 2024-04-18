import Foundation

final class ObjectIconActionHandler: ObjectIconActionHandlerProtocol {
    
    @Injected(\.objectHeaderUploadingService)
    private var objectHeaderUploadingService: ObjectHeaderUploadingServiceProtocol
    
    func handleIconAction(objectId: String, spaceId: String, action: ObjectIconPickerAction) {
        Task {
            try await objectHeaderUploadingService.handleIconAction(
                objectId: objectId,
                spaceId: spaceId,
                action: action
            )
        }
    }
}
