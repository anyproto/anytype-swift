import Foundation

struct BottomAlertButton {
    let title: String
    var isDistructive: Bool = false
    var autoDismiss: Bool = true
    let action: () -> Void
}

struct BottomAlert {
    let title: String
    let message: String
    let leftButton: BottomAlertButton
    let rightButton: BottomAlertButton
}

// MARK: - Helpers

extension FloaterAlertView {
    init(bottomAlert: BottomAlert) {
        self.init(
            title: bottomAlert.title,
            description: bottomAlert.message,
            leftButtonData: StandardButtonModel(bottomAlertButton: bottomAlert.leftButton),
            rightButtonData: StandardButtonModel(bottomAlertButton: bottomAlert.rightButton),
            dismissAfterLeftTap: bottomAlert.leftButton.autoDismiss,
            dismissAfterRightTap: bottomAlert.rightButton.autoDismiss
        )
    }
}

extension StandardButtonModel {
    init(bottomAlertButton: BottomAlertButton) {
        self.init(
            text: bottomAlertButton.title,
            style: bottomAlertButton.isDistructive ? .warningLarge : .secondaryLarge,
            action: bottomAlertButton.action
        )
    }
}
