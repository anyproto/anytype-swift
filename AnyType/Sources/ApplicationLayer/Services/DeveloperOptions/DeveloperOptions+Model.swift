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
            self.workflow = .init(authentication: .init(shouldSkipLogin: false, alphaInvitePasscode: ""), dashboard: .init(hasCustomModalPresentation: false, cellsHaveActionsOnLongTap: false),
                                  mainDocumentEditor: .init(useUIKit: true, textEditor: .init(shouldHaveUniqueText: true, shouldEmbedSwiftUIIntoCell: false, shouldShowCellsIndentation: false)))
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
            var alphaInvitePasscode: String
        }
        
        struct Dashboard: CodableAndDictionary {
            var hasCustomModalPresentation: Bool
            var cellsHaveActionsOnLongTap: Bool
        }
        
        struct MainDocumentEditor: CodableAndDictionary {
            struct TextEditor: CodableAndDictionary {
                var shouldHaveUniqueText: Bool
                var shouldEmbedSwiftUIIntoCell: Bool
                var shouldShowCellsIndentation: Bool
            }
            var useUIKit: Bool
            var textEditor: TextEditor
        }
        
        var authentication: Authentication
        var dashboard: Dashboard
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
