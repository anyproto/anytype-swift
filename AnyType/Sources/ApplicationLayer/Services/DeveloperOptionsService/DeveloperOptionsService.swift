import Foundation
import os
import Combine


// Maybe we don't need it later.
// We could copy default configuration, for example.
// Or we could merge default configuration with user configuration.
extension UserDefaultsConfig {
    @UserDefault("DeveloperOptions", defaultValue: nil)
    static var developerOptions: [String : AnyObject]?
}

class DeveloperOptionsService {
    private var settingsDidChangeSubject: PassthroughSubject<Settings, Never> = .init()
    private(set) var settingsDidChangePublisher: AnyPublisher<Settings, Never> = .empty()
    init() {
        self.settingsDidChangePublisher = self.settingsDidChangeSubject.eraseToAnyPublisher()
    }

    typealias Settings = DeveloperOptionsSettings
    
    func defaultSettings() -> Settings {
        // read from plist file.
        // Settings are codable.
        // Look at Default plist file.
        (try? DeveloperOptionsDriver.Default.settings().flatMap(Settings.create)) ?? .default
    }
    
    func assertAlphaInviteCodeIsEmptyInRelease() {
        if !self.currentSettings.workflow.authentication.alphaInvitePasscode.isEmpty && PlistReader.DeveloperOptions.isRelease() {
            os_log(.error, "alpha invite passcode should be empty in release build")
        }
    }
    
    var current: Settings {
        // TODO: Remove later.
        self.assertAlphaInviteCodeIsEmptyInRelease()
        return currentSettings
    }
    
    fileprivate var currentSettings: Settings {
        // Dump if needed.
//        Driver.Default.save(self.defaultSettings().dictionary())
        
        return (try? DeveloperOptionsDriver.settings().flatMap(Settings.create)) ?? self.defaultSettings()
    }
    
    // Or restore settings, hah!
    func runAtFirstTime() {
        // create developer settings first.
        self.resetToDefaults()
    }

    // MARK: Update
    func update(settings: Settings?) {
        guard let settings = settings, let dictionary = settings.dictionary() else { return }
        DeveloperOptionsDriver.save(dictionary)
        self.settingsDidChangeSubject.send(settings)
    }
    func resetToDefaults() {
        self.update(settings: self.defaultSettings())
    }
}
