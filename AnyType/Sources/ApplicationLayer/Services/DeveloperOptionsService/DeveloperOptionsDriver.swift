import Foundation
import os

class DeveloperOptionsDriver {
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
            
            os_log(.info, "temporaryFile: %s", temporaryFile)
            
            let result = try? settings.flatMap(DeveloperOptionsSettings.create).flatMap{["Settings": $0]}.flatMap(encoder.encode)
            
            _ = FileManager.default.createFile(atPath: temporaryFile, contents: result, attributes: nil)
        }
    }
}
