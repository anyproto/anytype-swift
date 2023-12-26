import Foundation

struct BottomAlertButtonLegacy {
    let title: String
    var isDistructive: Bool = false
    var autoDismiss: Bool = true
    let action: () -> Void
}

struct BottomAlertLegacy {
    let title: String
    let message: String
    let leftButton: BottomAlertButtonLegacy
    let rightButton: BottomAlertButtonLegacy
}

// MARK: - Helpers

extension FloaterAlertView {
    init(bottomAlert: BottomAlertLegacy) {
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
    init(bottomAlertButton: BottomAlertButtonLegacy) {
        self.init(
            text: bottomAlertButton.title,
            style: bottomAlertButton.isDistructive ? .warningLarge : .secondaryLarge,
            action: bottomAlertButton.action
        )
    }
}
