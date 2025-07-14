import UIKit

struct AlertModel {
    struct ButtonModel: Sendable {
        let title: String
        let style: UIAlertAction.Style
        let action: @Sendable () -> Void
    }

    let title: String?
    let message: String?
    let buttons: [ButtonModel]

}

extension AlertModel.ButtonModel {
    static let cancel = AlertModel.ButtonModel(title: Loc.cancel, style: .cancel, action: { })
    static let ok = AlertModel.ButtonModel(title: Loc.ok, style: .default, action: { })
}

extension AlertModel {
    static func undoAlertModel(undoAction: @escaping @Sendable () -> Void) -> AlertModel {
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
