import SwiftUI


@MainActor
final class AlertsFactory {
    // TODO: Remove with LegacyLoginView
    static func goToSettingsAlert(title: String) -> Alert {
        Alert(
            title: Text(verbatim: title),
            message: Text(verbatim: Loc.Alert.CameraPermissions.goToSettings),
            primaryButton:
                    .default(Text(Loc.Alert.CameraPermissions.settings)) {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    },
            secondaryButton: .default(Text(Loc.cancel))
        )
    }

    static func alertController(from alertModel: AlertModel) -> UIAlertController {
        let alertController = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )

        alertModel.buttons.forEach { item in
            let action = UIAlertAction(
                title: item.title,
                style: item.style,
                handler: { _ in item.action() }
            )

            alertController.addAction(action)
        }

        return alertController
    }
}
