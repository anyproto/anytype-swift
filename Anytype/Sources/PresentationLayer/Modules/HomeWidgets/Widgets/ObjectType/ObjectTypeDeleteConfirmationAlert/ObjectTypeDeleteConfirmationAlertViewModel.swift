import Foundation
import SwiftUI
import Services

@MainActor
final class ObjectTypeDeleteConfirmationAlertViewModel: ObservableObject {
    
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    
    private let data: ObjectTypeDeleteConfirmationAlertData
    
    init(data: ObjectTypeDeleteConfirmationAlertData) {
        self.data = data
    }
    
    func onTapDelete() async throws {
        try await objectActionsService.setArchive(objectIds: [data.typeId], true)
    }
}
