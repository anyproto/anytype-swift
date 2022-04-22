//
//  AlertsFactory.swift
//  Anytype
//
//  Created by Dmitry Bilienko on 29.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

final class AlertsFactory {
    static func goToSettingsAlert(title: String) -> Alert {
        Alert(
            title: Text(title),
            message: Text("Alert.CameraPermissions.GoToSettings".localized),
            primaryButton:
                    .default(Text("Alert.CameraPermissions.Settings".localized)) {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    },
            secondaryButton: .default(Text("Cancel".localized))
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
