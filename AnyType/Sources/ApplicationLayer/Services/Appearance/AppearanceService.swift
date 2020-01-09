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

class AppearanceService: BaseService {
    let assets = AssetsStorage.Local()
    let schemes = Schemes()
}

extension AppearanceService {
    func setupSchemes() {
        self.resetToDefaults()
        self.apply()
    }

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

    func apply() {

    }
}

extension AppearanceService {
    override func setup() {
        self.setupSchemes()
    }
}

enum Global {
    enum OurEnvironmentKeys {
        struct AssetsCatalog {}
        struct AppearanceService {}
    }
}

import SwiftUI
extension Global.OurEnvironmentKeys.AssetsCatalog: EnvironmentKey {
    static var defaultValue = AssetsStorage.Local()
}

extension Global.OurEnvironmentKeys.AppearanceService: EnvironmentKey {
    static var defaultValue = ServicesManager.shared.service(for: AppearanceService.self)!
}

extension EnvironmentValues {
    var assetsCatalog: AssetsStorage.Local {
        get {
            self[Global.OurEnvironmentKeys.AssetsCatalog.self]
        }
        set {
            self[Global.OurEnvironmentKeys.AssetsCatalog.self] = newValue
        }
    }
    var servicesAppearance: AppearanceService {
        get {
            self[Global.OurEnvironmentKeys.AppearanceService.self]
        }
        set {
            self[Global.OurEnvironmentKeys.AppearanceService.self] = newValue
        }
    }
}
