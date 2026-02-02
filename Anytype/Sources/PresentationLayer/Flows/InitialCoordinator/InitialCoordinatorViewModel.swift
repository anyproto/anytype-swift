import Foundation
import Sentry
import UIKit
import AnytypeCore
import Services

@MainActor
@Observable
final class InitialCoordinatorViewModel {

    @ObservationIgnored @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    @ObservationIgnored @Injected(\.basicUserInfoStorage)
    private var basicUserInfoStorage: any BasicUserInfoStorageProtocol
    @ObservationIgnored @Injected(\.middlewareConfigurationProvider)
    private var middlewareConfigurationProvider: any MiddlewareConfigurationProviderProtocol
    @ObservationIgnored @Injected(\.applicationStateService)
    private var applicationStateService: any ApplicationStateServiceProtocol
    @ObservationIgnored @Injected(\.seedService)
    private var seedService: any SeedServiceProtocol
    @ObservationIgnored @Injected(\.localAuthService)
    private var localAuthService: any LocalAuthServiceProtocol
    @ObservationIgnored @Injected(\.localRepoService)
    private var localRepoService: any LocalRepoServiceProtocol

    var showWarningAlert: Bool = false
    var showSaveBackupAlert: Bool = false
    var toastBarData: ToastBarData?
    var middlewareShareFile: URL? = nil
    var localStoreURL: URL? = nil
    var secureAlertData: SecureAlertData?
    
    var userId: String {
        basicUserInfoStorage.usersId
    }
    
    func onAppear() {
        checkCrash()
        AppIconManager.shared.migrateIcons()
    }
    
    func contunueWithoutLogout() {
        showLoginOrAuth()
        userDefaults.showUnstableMiddlewareError = false
    }
    
    func contunueWithLogout() {
        basicUserInfoStorage.usersId = ""
        showLoginOrAuth()
        userDefaults.showUnstableMiddlewareError = false
    }
    
    func contunueWithTrust() {
        showLoginOrAuth()
        userDefaults.showUnstableMiddlewareError = false
    }
    
    func onCopyPhrase() {
        Task {
            try await localAuthWithContinuation(reason: Loc.accessToKeyFromKeychain) { [weak self] in
                guard let self else { return }
                let phrase = try seedService.obtainSeed()
                UIPasteboard.general.string = phrase
                toastBarData = ToastBarData(Loc.copied)
            }
        }
    }
    
    func onShareMiddleware() {
        Task {
            try await localAuthWithContinuation(reason: "Share working directory") { [weak self] in
                guard let self else { return }
                let source = localRepoService.middlewareRepoURL
                let to = FileManager.default.createTempDirectory().appendingPathComponent("workingDirectory.zip")
                try FileManager.default.zipItem(at: source, to: to)
                middlewareShareFile = to
            }
        }
    }
    
    func onContinueCrashAlert() {
        checkTestVersion()
    }
    
    // MARK: - Private
    
    private func showLoginOrAuth() {
        if basicUserInfoStorage.usersId.isNotEmpty {
            applicationStateService.state = .launch
        } else {
            applicationStateService.state = .auth
        }
    }
    
    private func localAuthWithContinuation(reason: String, continuation: @escaping () async throws -> Void) async throws {
        do {
            try await localAuthService.auth(reason: reason)
            try await continuation()
        } catch LocalAuthServiceError.passcodeNotSet {
            secureAlertData = SecureAlertData(completion: { proceed in
                guard proceed else { return }
                try await continuation()
            })
        }
    }
    
    private func checkTestVersion() {
        #if DEBUG || RELEASE_NIGHTLY
        Task { @MainActor in
            do {
                let version = try await middlewareConfigurationProvider.libraryVersion()
                let isUnstableVersion = !version.hasPrefix("v")
                if isUnstableVersion {
                    if (basicUserInfoStorage.usersId.isEmpty || userDefaults.showUnstableMiddlewareError) {
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
