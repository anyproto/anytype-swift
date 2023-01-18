import UIKit
import AnytypeCore

final class UndoRedoViewModel: ObservableObject {
    struct ButtonModel: Identifiable {
        let id: String
        let title: String
        let imageAsset: ImageAsset
        let action: () -> Void
    }

    var onErrorHandler: RoutingAction<String>?
    
    lazy private(set) var buttonModels = buildButtonModels()

    private let objectId: String
    private let objectActionsService: ObjectActionsServiceProtocol

    init(
        objectId: String,
        objectActionsService: ObjectActionsServiceProtocol = ObjectActionsService()
    ) {
        self.objectId = objectId
        self.objectActionsService = objectActionsService
    }

    func undo() {
        do {
            try objectActionsService.undo(objectId: objectId)
        } catch let error as ObjectActionsServiceError {
            onErrorHandler?(error.message)
        } catch {
            anytypeAssertionFailure("Unknown error", domain: .editorPage)
        }
    }

    func redo() {
        do {
            try objectActionsService.redo(objectId: objectId)
        } catch let error as ObjectActionsServiceError {
            onErrorHandler?(error.message)
        } catch {
            anytypeAssertionFailure("Unknown error", domain: .editorPage)
        }
    }

    private func buildButtonModels() -> [ButtonModel] {
        [
            .init(
                id: "undo",
                title: "Undo",
                imageAsset: .undo,
                action: { [weak self] in self?.undo() }
            ),
            .init(
                id: "redo",
                title: "Redo",
                imageAsset: .redo,
                action: { [weak self] in self?.redo() }
            )
        ]
    }
}
