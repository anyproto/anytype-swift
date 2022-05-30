import UIKit
import AnytypeCore

final class UndoRedoViewModel: ObservableObject {
    struct ButtonModel: Identifiable {
        let id: String
        let title: String
        let image: UIImage
        let action: () -> Void
    }

    lazy var buttonModels = buildButtonModels()

    private let objectId: String
    private let objectActionsService: ObjectActionsServiceProtocol
    private let toastPresenter: ToastPresenter

    init(
        objectId: String,
        objectActionsService: ObjectActionsServiceProtocol = ObjectActionsService(),
        toastPresenter: ToastPresenter
    ) {
        self.objectId = objectId
        self.objectActionsService = objectActionsService
        self.toastPresenter = toastPresenter
    }

    func undo() {
        do {
            try objectActionsService.undo(objectId: objectId)
        } catch let error as ObjectActionsServiceError {
            toastPresenter.show(message: error.message)
        } catch {
            anytypeAssertionFailure("Unknown error", domain: .editorPage)
        }
    }

    func redo() {
        do {
            try objectActionsService.redo(objectId: objectId)
        } catch let error as ObjectActionsServiceError {
            toastPresenter.show(message: error.message)
        } catch {
            anytypeAssertionFailure("Unknown error", domain: .editorPage)
        }
    }

    private func buildButtonModels() -> [ButtonModel] {
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
