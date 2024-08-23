import Foundation
import AnytypeCore

protocol AppVersionServiceProtocol: AnyObject {
    func prepareData()
    func newVersionIsAvailable() async throws -> Bool
}

actor AppVersionService: AppVersionServiceProtocol {
    
    @Injected(\.userDefaultsStorage)
    private var userDefaults: UserDefaultsStorageProtocol
    
    private var vesionChecked = false
    private var needsUpdate = false
    
    nonisolated func prepareData() {
        Task {
            try await updateData()
        }
    }
    
    func newVersionIsAvailable() async throws -> Bool {
        if vesionChecked {
            return needsUpdate
        }
        
        try await updateData()
        
        return needsUpdate
    }
    
    // MARK: - Private
    
    private func updateData() async throws {
        vesionChecked = true
        
        guard let appVersion = currentVersion() else { return }
        
        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(AppId.production)") else { return }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        
        let result = try decoder.decode(LookupResponse.self, from: data)
        
        guard let newAppVersion = result.results.first?.version else { return }
        
        needsUpdate = appVersion.versionCompare(newAppVersion) == .orderedAscending
    }
    
    private func currentVersion() -> String? {
        if userDefaults.currentVersionOverride.isNotEmpty {
            return userDefaults.currentVersionOverride
        }
        
        return MetadataProvider.appVersion
    }
}
