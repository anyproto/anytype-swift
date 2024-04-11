import UIKit
import AnytypeCore
import Services

@MainActor
final class UndoRedoViewModel: ObservableObject {
    
    @Injected(\.objectActionsService)
    private var objectActionsService: ObjectActionsServiceProtocol
    
    private let objectId: String

    init(
        objectId: String
    ) {
        self.objectId = objectId
    }

    func undo() async throws {
        AnytypeAnalytics.instance().logUndo()
        try await objectActionsService.undo(objectId: objectId)
    }

    func redo() async throws {
        AnytypeAnalytics.instance().logRedo()
        try await objectActionsService.redo(objectId: objectId)
    }
}
