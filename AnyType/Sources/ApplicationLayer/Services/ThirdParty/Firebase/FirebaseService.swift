//
//  FirebaseService.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 28.10.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Firebase
import os

private extension Logging.Categories {
    static let servicesFirebaseService: Self = "ServicesLayer.FirebaseService"
}

class FirebaseService: ServicesSetupProtocol {
    private static let defaultSettingsFile = "GoogleService-Info"
    let settingsFile: String
    init() {
        self.settingsFile = Self.defaultSettingsFile
    }

    func setup() {
        let path = Bundle(for: Self.self).path(forResource: self.settingsFile, ofType: "plist")
        if let path = path, let options = FirebaseOptions.init(contentsOfFile: path) {
            DispatchQueue.main.async {
                FirebaseApp.configure(options: options)
            }
        }
        else {
            let logger = Logging.createLogger(category: .servicesFirebaseService)
            os_log(.error, log: logger, "Can't create options with file at path: %@", String(describing: self.settingsFile))
        }
    }
}
