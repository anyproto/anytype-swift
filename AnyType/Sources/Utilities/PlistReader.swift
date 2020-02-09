//
//  PlistReader.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 29/09/2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

class PlistReader {
    typealias Output = [String : AnyObject]
    var dictionary: Output?
    
    required init(_ dictionary: Output?) {
        self.dictionary = dictionary
    }
    
    class func create() -> Self? {
        return .init([:])
    }
    
    class func create(filename: String) -> Self? {
        Bundle(for: self).url(forResource: filename, withExtension: "plist")
            .flatMap{try? Data(contentsOf: $0)}
            // Without any options PropertyListSerialization would parse ANY .plist file in ANY available .PropertyListFormat.
            .flatMap{try? PropertyListSerialization.propertyList(from: $0, options: [], format: nil)}
            .flatMap{$0 as? Output}
            .flatMap(Self.init)
    }
    
    class func createVariant(name: String, configuration: BuildConfiguration.Configuration? = nil) -> Self? {
        func plistName(_ name: String, _ configuration: BuildConfiguration.Configuration?, _ defaultConfigurationName: String) -> String {
            let configurationSuffix = (configuration?.rawValue ?? defaultConfigurationName)
            return name + "." + configurationSuffix
        }
        
        let newName = plistName(name, configuration, BuildConfiguration.current.buildConfigurationName ?? "")
        return self.create(filename: newName)
    }
}

extension PlistReader {
    class BuildConfiguration: PlistReader {
        enum Configuration: String {
            case Debug
            case Release
            case PublicBeta
        }
        
        override class func create() -> Self? {
            .init(Bundle.main.infoDictionary as Output?)
        }
        
        static var current: BuildConfiguration = .init(Bundle.main.infoDictionary as Output?)
        
        var userDefinedSettings: Output? {
            self.dictionary?["UserDefinedSettings"] as? Output
        }
        
        var buildConfigurationName: String? {
            self.userDefinedSettings?["BuildConfigurationName"] as? String
        }
        
        // MARK: Computed
        var buildConfiguration: Configuration? {
            Configuration.init(rawValue: self.buildConfigurationName ?? "")
        }
    }
}

extension PlistReader {
    /// DeveloperOptions.
    /// NOTE: We use createVariant, so, we need minimum two variants ( debug and release options ).
    /// Their names are
    /// DeveloperOptions.Debug.plist
    /// DeveloperOptions.Release.plist
    class DeveloperOptions: PlistReader {
        override class func create() -> Self? {
            self.createVariant(name: "DeveloperOptions")
        }
    }

    var settings: Output? {
        self.dictionary?["Settings"] as? Output
    }
}
