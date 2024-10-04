import Foundation
import AnytypeCore

protocol AppVersionTrackerProtocol: AnyObject {
    func trackLaunch()
    func firstVersionLaunch(_ version: String, ignoreForNewUser: Bool) async -> Bool
    func currentVersion() async -> String?
}

actor AppVersionTracker: AppVersionTrackerProtocol {
    
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    
    @UserDefault("UserData.prevLaunchedAppVersion", defaultValue: nil)
    var prevLaunchedAppVersion: String?
    @UserDefault("UserData.currentLaunchedAppVersion", defaultValue: nil)
    var currentLaunchedAppVersion: String?
    
    private var isFirstAppLaunch = false
    
    nonisolated func trackLaunch() {
        Task {
            await storeData()
        }
    }
    
    func firstVersionLaunch(_ version: String, ignoreForNewUser: Bool) async -> Bool {
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
    
    func currentVersion() async -> String? {
        if userDefaults.currentVersionOverride.isNotEmpty {
            return userDefaults.currentVersionOverride
        }
        
        return MetadataProvider.appVersion
    }
    
    private func storeData() async {
        if userDefaults.installedAtDate.isNil {
            isFirstAppLaunch = true
            userDefaults.installedAtDate = Date()
        }
        
        prevLaunchedAppVersion = currentLaunchedAppVersion
        currentLaunchedAppVersion = await currentVersion()
    }
}
