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
        
        class Default {
            
            static let encoder: PropertyListEncoder = {
                let encoder = PropertyListEncoder()
                encoder.outputFormat = .xml
                return encoder
            }()
            
            static func settings() -> [String : AnyObject]? {
                PlistReader.DeveloperOptions.read()?.settings
            }
            
            static func save(_ settings: [String : AnyObject]?) {
                // We want to save them somewhere.
                let directory = NSTemporaryDirectory()
                let temporaryFile = directory.appending("/Settings.plist")
                
                print("temporaryFile: \(temporaryFile)")
                
                let result = try? settings.flatMap(Settings.create).flatMap{["Settings": $0]}.flatMap(encoder.encode)
                
                _ = FileManager.default.createFile(atPath: temporaryFile, contents: result, attributes: nil)
            }
            
        }
    }
}

extension DeveloperOptions.Service {
    typealias Settings = DeveloperOptions.Settings
    
    func defaultSettings() -> Settings {
        // read from plist file.
        // Settings are codable.
        // Look at Default plist file.
//        let debug = Settings.Debug(enabled: false)
//        let authentication = Settings.Workflow.Authentication(shouldSkipLogin: false)
//        let mainDocumentEditor = Settings.Workflow.MainDocumentEditor(useUIKit: false)
//        let workflow = Settings.Workflow(authentication: authentication, mainDocumentEditor: mainDocumentEditor)
//        let result = Settings.init(debug: debug, workflow: workflow)
        (try? Driver.Default.settings().flatMap(Settings.create)) ?? .default
    }
    
    var current: Settings {
        currentSettings
    }
    
    fileprivate var currentSettings: Settings {
        // Dump if needed.
//        Driver.Default.save(self.defaultSettings().dictionary())
        
        return (try? Driver.settings().flatMap(Settings.create)) ?? self.defaultSettings()
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
