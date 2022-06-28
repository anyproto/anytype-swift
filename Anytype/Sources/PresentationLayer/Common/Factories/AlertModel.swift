import UIKit

struct AlertModel {
    struct ButtonModel {
        let title: String
        let style: UIAlertAction.Style
        let action: () -> Void
    }

    let title: String?
    let message: String?
    let buttons: [ButtonModel]

}

extension AlertModel.ButtonModel {
    static var cancel: Self = .init(title: Loc.cancel, style: .cancel, action: { })
}

extension AlertModel {
    static func undoAlertModel(undoAction: @escaping () -> Void) -> AlertModel {
        AlertModel(
            title: Loc.undoTyping,
            message: nil,
            buttons: [
                .cancel,
                .init(title: Loc.undo, style: .default, action: undoAction)
            ]
        )
    }
}
