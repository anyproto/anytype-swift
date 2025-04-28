import Foundation
import Sentry
import UIKit
import AnytypeCore
import Services

@MainActor
final class InitialCoordinatorViewModel: ObservableObject {
    
    @Injected(\.userDefaultsStorage)
    var userDefaults: any UserDefaultsStorageProtocol
    @Injected(\.middlewareConfigurationProvider)
    private var middlewareConfigurationProvider: any MiddlewareConfigurationProviderProtocol
    @Injected(\.applicationStateService)
    private var applicationStateService: any ApplicationStateServiceProtocol
    @Injected(\.seedService)
    private var seedService: any SeedServiceProtocol
    @Injected(\.localAuthService)
    private var localAuthService: any LocalAuthServiceProtocol
    @Injected(\.localRepoService)
    private var localRepoService: any LocalRepoServiceProtocol
    
    @Published var showWarningAlert: Bool = false
    @Published var showSaveBackupAlert: Bool = false
    @Published var toastBarData: ToastBarData?
    @Published var middlewareShareFile: URL? = nil
    @Published var localStoreURL: URL? = nil
    
    func onAppear() {
        checkCrash()
        AppIconManager.shared.migrateIcons()
    }
    
    func contunueWithoutLogout() {
        showLoginOrAuth()
        userDefaults.showUnstableMiddlewareError = false
    }
    
    func contunueWithLogout() {
        userDefaults.usersId = ""
        showLoginOrAuth()
        userDefaults.showUnstableMiddlewareError = false
    }
    
    func contunueWithTrust() {
        showLoginOrAuth()
        userDefaults.showUnstableMiddlewareError = false
    }
    
    func onCopyPhrase() {
        Task {
            try await localAuthService.auth(reason: Loc.accessToKeyFromKeychain)
            let phrase = try seedService.obtainSeed()
            UIPasteboard.general.string = phrase
            toastBarData = ToastBarData(Loc.copied)
        }
    }
    
    func onShareMiddleware() {
        Task {
            try await localAuthService.auth(reason: "Share working directory")
            let source = localRepoService.middlewareRepoURL
            let to = FileManager.default.createTempDirectory().appendingPathComponent("workingDirectory.zip")
            try FileManager.default.zipItem(at: source, to: to)
            middlewareShareFile = to
        }
    }
    
    func onContinueCrashAlert() {
        checkTestVersion()
    }
    
    // MARK: - Private
    
    private func showLoginOrAuth() {
        if userDefaults.usersId.isNotEmpty {
            applicationStateService.state = .login
        } else {
            applicationStateService.state = .auth
        }
    }
    
    private func checkTestVersion() {
        #if DEBUG || RELEASE_NIGHTLY
        Task { @MainActor in
            do {
                let version = try await middlewareConfigurationProvider.libraryVersion()
                let isUnstableVersion = !version.hasPrefix("v")
                if isUnstableVersion {
                    if (userDefaults.usersId.isEmpty || userDefaults.showUnstableMiddlewareError) {
                        showWarningAlert.toggle()
                    } else {
                        showLoginOrAuth()
                    }
                } else {
                    showLoginOrAuth()
                    userDefaults.showUnstableMiddlewareError = true
                }
            } catch {
                showLoginOrAuth()
            }
        }
        #else
        showLoginOrAuth()
        #endif
    }
    
    private func checkCrash() {
        #if DEBUG || RELEASE_NIGHTLY
        if SentrySDK.crashedLastRun {
            showSaveBackupAlert = true
        } else{
            checkTestVersion()
        }
        #else
        checkTestVersion()
        #endif
    }
}
