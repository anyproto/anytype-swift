import Foundation

extension FloaterAlertView {
    static func deleteSpaceAlert(spaceName: String, onDelete: @escaping () -> Void) -> Self {
        FloaterAlertView(
            title: Loc.SpaceSettings.DeleteAlert.title(spaceName),
            description: Loc.SpaceSettings.DeleteAlert.message,
            leftButtonData: StandardButtonModel(text: Loc.back, style: .secondaryLarge, action: {
                AnytypeAnalytics.instance().logClickDeleteSpaceWarning(type: .cancel)
            }),
            rightButtonData: StandardButtonModel(text: Loc.delete, style: .warningLarge, action: {
                AnytypeAnalytics.instance().logClickDeleteSpaceWarning(type: .delete)
                onDelete()
            }),
            dismissAfterLeftTap: true,
            dismissAfterRightTap: true
        )
    }
}
