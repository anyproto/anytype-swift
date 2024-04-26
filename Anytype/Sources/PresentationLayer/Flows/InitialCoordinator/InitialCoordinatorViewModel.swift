import Foundation
import Sentry
import UIKit
import AnytypeCore
import Services

@MainActor
final class InitialCoordinatorViewModel: ObservableObject {
    
    private let middlewareConfigurationProvider: MiddlewareConfigurationProviderProtocol
    private let applicationStateService: ApplicationStateServiceProtocol
    private let seedService: SeedServiceProtocol
    private let localAuthService: LocalAuthServiceProtocol
    private let localRepoService: LocalRepoServiceProtocol
    
    @Published var showWarningAlert: Bool = false
    @Published var showSaveBackupAlert: Bool = false
    @Published var toastBarData: ToastBarData = .empty
    @Published var middlewareShareFile: URL? = nil
    @Published var localStoreURL: URL? = nil
    
    init(
        middlewareConfigurationProvider: MiddlewareConfigurationProviderProtocol,
        applicationStateService: ApplicationStateServiceProtocol,
        seedService: SeedServiceProtocol,
        localAuthService: LocalAuthServiceProtocol,
        localRepoService: LocalRepoServiceProtocol
    ) {
        self.middlewareConfigurationProvider = middlewareConfigurationProvider
        self.applicationStateService = applicationStateService
        self.seedService = seedService
        self.localAuthService = localAuthService
        self.localRepoService = localRepoService
    }
    
    func onAppear() {
        checkCrash()
    }
    
    func contunueWithoutLogout() {
        showLoginOrAuth()
        UserDefaultsConfig.showUnstableMiddlewareError = false
    }
    
    func contunueWithLogout() {
        UserDefaultsConfig.usersId = ""
        showLoginOrAuth()
        UserDefaultsConfig.showUnstableMiddlewareError = false
    }
    
    func contunueWithTrust() {
        showLoginOrAuth()
        UserDefaultsConfig.showUnstableMiddlewareError = false
    }
    
    func onCopyPhrase() {
        Task {
            try await localAuthService.auth(reason: Loc.accessToSecretPhraseFromKeychain)
            let phrase = try seedService.obtainSeed()
            UIPasteboard.general.string = phrase
            toastBarData = ToastBarData(text: Loc.copied, showSnackBar: true)
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
        if UserDefaultsConfig.usersId.isNotEmpty {
            applicationStateService.state = .login
        } else {
            applicationStateService.state = .auth
        }
    }
    
    private func checkTestVersion() {
        #if DEBUG
        Task { @MainActor in
            do {
                let version = try await middlewareConfigurationProvider.libraryVersion()
                let isUnstableVersion = !version.hasPrefix("v")
                if isUnstableVersion {
                    if (UserDefaultsConfig.usersId.isEmpty || UserDefaultsConfig.showUnstableMiddlewareError) {
                        showWarningAlert.toggle()
                    } else {
                        showLoginOrAuth()
                    }
                } else {
                    showLoginOrAuth()
                    UserDefaultsConfig.showUnstableMiddlewareError = true
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
        #if DEBUG
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
