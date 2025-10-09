import Foundation
import AnytypeCore

protocol AppVersionTrackerProtocol: AnyObject {
    func trackLaunch()
    func firstVersionLaunch(_ version: String, ignoreForNewUser: Bool) -> Bool
    func reachedVersion(_ version: String) -> Bool
    func currentVersion() -> String?
}

final class AppVersionTracker: AppVersionTrackerProtocol {
    
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    
    @UserDefault("UserData.prevLaunchedAppVersion", defaultValue: nil)
    private var prevLaunchedAppVersion: String?
    @UserDefault("UserData.currentLaunchedAppVersion", defaultValue: nil)
    private var currentLaunchedAppVersion: String?
    @UserDefault("UserData.isFirstAppLaunch", defaultValue: false)
    private var isFirstAppLaunch: Bool
    
    func trackLaunch() {
        storeData()
    }
    
    func firstVersionLaunch(_ version: String, ignoreForNewUser: Bool) -> Bool {
        guard let currentLaunchedAppVersion, version.isNotEmpty else {
            return false
        }
        
        if isFirstAppLaunch, ignoreForNewUser {
            return false
        }
        
        guard let prevLaunchedAppVersion else {
            return true
        }
        
        guard prevLaunchedAppVersion.versionCompare(currentLaunchedAppVersion) != .orderedSame else {
            return false
        }
        
        let prevResult = prevLaunchedAppVersion.versionCompare(version)
        let currentResult = currentLaunchedAppVersion.versionCompare(version)
        
        
        if prevResult == .orderedAscending &&
            (currentResult == .orderedDescending || currentResult == .orderedSame) {
            return true
        } else {
            return false
        }
    }
    
    func reachedVersion(_ version: String) -> Bool {
        guard let currentLaunchedAppVersion, version.isNotEmpty else {
            return false
        }
        let result = currentLaunchedAppVersion.versionCompare(version)
        return result == .orderedDescending || result == .orderedSame
    }
    
    func currentVersion() -> String? {
        if userDefaults.currentVersionOverride.isNotEmpty {
            return userDefaults.currentVersionOverride
        }
        
        return MetadataProvider.appVersion
    }
    
    private func storeData() {
        let installedAtDateIsNil = userDefaults.installedAtDate.isNil
        if installedAtDateIsNil {
            userDefaults.installedAtDate = Date()
        }
        
        isFirstAppLaunch = installedAtDateIsNil
        prevLaunchedAppVersion = currentLaunchedAppVersion
        currentLaunchedAppVersion = currentVersion()
        
        // Do not show tip for new users
        if isFirstAppLaunch {
            ChatCreationTip().invalidate(reason: .displayCountExceeded)
        }
    }
}
