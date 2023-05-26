import Foundation

struct BottomAlertButton {
    let title: String
    let isDistructive: Bool
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
            rightButtonData: StandardButtonModel(bottomAlertButton: bottomAlert.rightButton)
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
