//
//  DeveloperOptions+Service.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 07.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension DeveloperOptions {
    class Service: BaseService {}
}

// Maybe we don't need it later.
// We could copy default configuration, for example.
// Or we could merge default configuration with user configuration.
extension UserDefaultsConfig {
    @UserDefault("DeveloperOptions", defaultValue: nil)
    static var developerOptions: [String : AnyObject]?
}

extension DeveloperOptions.Service {
    class Driver {
        typealias LocalStorage = UserDefaultsConfig
        static func settings() -> [String : AnyObject]? {
            LocalStorage.developerOptions
        }
        static func save(_ settings: [String : AnyObject]?) {
            LocalStorage.developerOptions = settings
        }
    }
}

extension DeveloperOptions.Service {
    typealias Settings = DeveloperOptions.Settings
    
    func defaultSettings() -> Settings {
        // read from plist file.
        // Settings are codable.
        // Look at Default plist file.
        let debug = Settings.Debug(enabled: false)
        let authentication = Settings.Workflow.Authentication(shouldSkipLogin: false)
        let mainDocumentEditor = Settings.Workflow.MainDocumentEditor(useUIKit: false)
        let workflow = Settings.Workflow(authentication: authentication, mainDocumentEditor: mainDocumentEditor)
        let result = Settings.init(debug: debug, workflow: workflow)
        return result
    }
    
    var current: Settings {
        currentSettings
    }
    
    fileprivate var currentSettings: Settings {
        // look at UserDefaults (?)
        guard let dictionary = Driver.settings() else {
            return self.defaultSettings()
        }
        
        guard let settings = try? Settings.create(dictionary: dictionary) else {
            return self.defaultSettings()
        }
        
//        let directory = NSTemporaryDirectory()
//        let file = directory.appending("/SettingsList.xml")
//        let data = try? Data(contentsOf: URL(fileURLWithPath: file))
//
//        let decoder = PropertyListDecoder()
//        let result = try! decoder.decode(Developer.Settings.self, from: data!)
        
//        let res = FileManager.default.createFile(atPath: file, contents: result, attributes: nil)
        return settings
    }
    
    // Or restore settings, hah!
    override func runAtFirstTime() {
        // create developer settings first.
        self.update(settings: self.defaultSettings())
    }
}

extension DeveloperOptions.Service {
    func update(settings: Settings?) {
        guard let settings = settings, let dictionary = settings.dictionary() else { return }
        Driver.save(dictionary)
    }
}
