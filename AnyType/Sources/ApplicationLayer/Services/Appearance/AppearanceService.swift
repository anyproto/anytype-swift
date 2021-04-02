//
//  AppearanceService.swift
//  AnyType
//
//  Created by Lobanov Dmitry on 19.11.19.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import UIKit

protocol AppearanceService_ColorSchemes_Base {
    func apply()
}

class AppearanceService: ServicesSetupProtocol {
    let assets = AssetsStorage.Local()
    let schemes = Schemes()

    func resetToDefaults() {
        if let scheme = schemes.scheme(for: Schemes.Global.SwiftUI.BaseText.self) {
            scheme.foregroundColor = assets.colors.main.yellow.value
            scheme.font = .body
            scheme.fontWeight = .medium
        }

        if let scheme = schemes.scheme(for: Schemes.Global.Appearance.BaseNavigationBar.self) {
            scheme.barTintColor = UIColor.green
        }
    }

    func setup() {
        resetToDefaults()
    }
}
