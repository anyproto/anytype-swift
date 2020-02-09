//
//  DeveloperOptions+Model.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 07.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension DeveloperOptions {
//    struct Model: Codable {
//        // codable model.
//    }
}

extension DeveloperOptions {
    struct Settings: CodableAndDictionary {
        var debug: Debug
//        var style: Style?
        var workflow: Workflow
//        var services: Services?
        private init() {
            self.debug = .init(enabled: false)
            self.workflow = .init(authentication: .init(shouldSkipLogin: false), mainDocumentEditor: .init(useUIKit: true))
        }
        static var `default`: Settings = .init()
    }
}

extension DeveloperOptions.Settings {
    struct Debug: CodableAndDictionary {
        var enabled: Bool // should be set to true to allow other options.
    }

    struct Workflow: CodableAndDictionary {
        struct Authentication: CodableAndDictionary {
            var shouldSkipLogin: Bool
        }
        
        struct MainDocumentEditor: CodableAndDictionary {
            var useUIKit: Bool
        }
        
        var authentication: Authentication
        var mainDocumentEditor: MainDocumentEditor
    }

//    struct Services: CodableAndDictionary {
//        struct Network: CodableAndDictionary {
//            var forceProduction: Bool?
//        }
//        var network: Network?
//    }

    func isRelease() -> Bool {
        return self.debug.enabled == false
    }
}
