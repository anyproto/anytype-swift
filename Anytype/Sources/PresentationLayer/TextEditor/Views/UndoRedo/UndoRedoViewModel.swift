import UIKit
import AnytypeCore
import Services

@MainActor
@Observable
final class UndoRedoViewModel {

    @ObservationIgnored
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol

    private let objectId: String

    var toastData: ToastBarData?
    
    init(
        objectId: String
    ) {
        self.objectId = objectId
    }

    func undo() async throws {
        do {
            try await objectActionsService.undo(objectId: objectId)
            AnytypeAnalytics.instance().logUndo(resultType: .true)
        } catch let error as ObjectActionsServiceError {
            toastData = ToastBarData(error.localizedDescription, type: .neutral)
            AnytypeAnalytics.instance().logUndo(resultType: .false)
        }
    }

    func redo() async throws {
        do {
            try await objectActionsService.redo(objectId: objectId)
            AnytypeAnalytics.instance().logRedo(resultType: .true)
        } catch let error as ObjectActionsServiceError {
            toastData = ToastBarData(error.localizedDescription, type: .neutral)
            AnytypeAnalytics.instance().logRedo(resultType: .false)
        }
    }
}
