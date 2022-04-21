import UIKit
import AnytypeCore

final class UndoRedoViewModel: ObservableObject {
    struct ButtonModels: Identifiable {
        let id: String
        let title: String
        let image: UIImage
        let action: () -> Void
    }

    lazy var buttonModels = buildButtonModels()

    private let objectId: AnytypeId
    private let objectActionsService: ObjectActionsServiceProtocol

    init(
        objectId: AnytypeId,
        objectActionsService: ObjectActionsServiceProtocol = ObjectActionsService()
    ) {
        self.objectId = objectId
        self.objectActionsService = objectActionsService
    }

    func undo() {
        objectActionsService.undo(objectId: objectId)
    }

    func redo() {
        objectActionsService.redo(objectId: objectId)
    }

    private func buildButtonModels() -> [ButtonModels] {
        [
            .init(
                id: "undo",
                title: "Undo",
                image: UIImage.editor.UndoRedo.undo,
                action: { [weak self] in self?.undo() }
            ),
            .init(
                id: "redo",
                title: "Redo",
                image: UIImage.editor.UndoRedo.redo,
                action: { [weak self] in self?.redo() }
            )
        ]
    }
}
