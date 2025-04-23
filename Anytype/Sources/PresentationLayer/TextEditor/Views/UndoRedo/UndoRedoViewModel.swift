import UIKit
import AnytypeCore
import Services

@MainActor
final class UndoRedoViewModel: ObservableObject {
    
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    
    private let objectId: String

    @Published var toastData: ToastBarData?
    
    init(
        objectId: String
    ) {
        self.objectId = objectId
    }

    func undo() async throws {
        AnytypeAnalytics.instance().logUndo()
        do {
            try await objectActionsService.undo(objectId: objectId)
        } catch let error as ObjectActionsServiceError {
            toastData = ToastBarData(error.localizedDescription, type: .neutral)
        }
    }

    func redo() async throws {
        do {
            AnytypeAnalytics.instance().logRedo()
            try await objectActionsService.redo(objectId: objectId)
        } catch let error as ObjectActionsServiceError {
            toastData = ToastBarData(error.localizedDescription, type: .neutral)
        }
    }
}
