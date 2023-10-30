import Foundation

extension FloaterAlertView {
    static func deleteSpaceAlert(spaceName: String, onDelete: @escaping () -> Void) -> Self {
        FloaterAlertView(
            title: Loc.SpaceSettings.DeleteAlert.title(spaceName),
            description: Loc.SpaceSettings.DeleteAlert.message,
            leftButtonData: StandardButtonModel(text: Loc.back, style: .secondaryLarge, action: { }),
            rightButtonData: StandardButtonModel(text: Loc.delete, style: .warningLarge, action: { onDelete() }),
            dismissAfterLeftTap: true,
            dismissAfterRightTap: true
        )
    }
}
