import SwiftUI
import Services
import AnytypeCore

@MainActor
@Observable
final class PrimaryAuthViewModel {

    var createAccountTaskId: String?
    var inProgress = false
    var errorText: String? {
        didSet { showError = errorText.isNotNil }
    }
    var showError: Bool = false

    // MARK: - State
    @ObservationIgnored
    private let state = JoinFlowState()

    // MARK: - Private
    @ObservationIgnored
    private weak var output: (any PrimaryAuthOutput)?

    @ObservationIgnored @Injected(\.serverConfigurationStorage)
    private var serverConfigurationStorage: any ServerConfigurationStorageProtocol
    @ObservationIgnored @Injected(\.appActionStorage)
    private var appActionStorage: AppActionStorage
    @ObservationIgnored @Injected(\.authService)
    private var authService: any AuthServiceProtocol
    @ObservationIgnored @Injected(\.seedService)
    private var seedService: any SeedServiceProtocol
    @ObservationIgnored @Injected(\.usecaseService)
    private var usecaseService: any UsecaseServiceProtocol
    @ObservationIgnored @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @ObservationIgnored @Injected(\.pushNotificationsPermissionService)
    private var pushNotificationsPermissionService: any PushNotificationsPermissionServiceProtocol

    init(output: (any PrimaryAuthOutput)?) {
        self.output = output
    }

    // MARK: - Public

    func onAppear() {
        AnytypeAnalytics.instance().logMainAuthScreenShow()
    }

    func startAppActionSubscription() async {
        for await action in appActionStorage.$action.values {
            guard let action else { continue }

            if (try? handleAppAction(action: action)).isNotNil {
                appActionStorage.action = nil
            }
        }
    }
    
    func onJoinButtonTap() {
        if state.mnemonic.isEmpty {
            createAccountTaskId = UUID().uuidString
        } else {
            onSuccess()
        }
    }
    
    func onLoginButtonTap() {
        output?.onLoginSelected()
    }
    
    func onSettingsButtonTap() {
        output?.onSettingsSelected()
    }
    
    func onDebugMenuTap() {
        output?.onDebugMenuSelected()
    }

    // MARK: - Create account step
    
    func createAccount() async {
        defer { createAccountTaskId = nil }
        AnytypeAnalytics.instance().logStartCreateAccount()
        inProgress = true
        
        do {
            state.mnemonic = try await authService.createWallet()
            let iconOption = IconColorStorage.randomOption()
            let account = try await authService.createAccount(
                name: "",
                iconOption: iconOption,
                imagePath: ""
            )
            await pushNotificationsPermissionService.registerForRemoteNotificationsIfNeeded()
            try await setDefaultSpaceInfo(account.info.accountSpaceId, iconOption: iconOption)
            try? seedService.saveSeed(state.mnemonic)
            
            onSuccess()
        } catch {
            createAccountError(error)
        }
    }
    
    private func setDefaultSpaceInfo(_ spaceId: String, iconOption: Int) async throws {
        guard spaceId.isNotEmpty else { return }
        _ = try? await usecaseService.setObjectImportDefaultUseCase(spaceId: spaceId)
        try? await workspaceService.workspaceSetDetails(
            spaceId: spaceId,
            details: [.name(Loc.myFirstSpace), .iconOption(iconOption)]
        )
    }
    
    private func onSuccess() {
        inProgress = false
        output?.onJoinSelected(state: state)
    }
    
    private func createAccountError(_ error: some Error) {
        inProgress = false
        errorText = error.localizedDescription
    }
    
    private func handleAppAction(action: AppAction) throws {
        switch action {
        case .createObjectFromQuickAction, .openObject:
            throw AuthViewModelError.unsupportedAppAction
        case .deepLink(let deeplink, _):
            switch deeplink {
            case .networkConfig(let config):
                try updateNetworkConfig(config)
            case .createObjectFromWidget, .showSharingExtension, .galleryImport, .invite, .object, .membership, .hi:
                throw AuthViewModelError.unsupportedAppAction
            }
        }
    }
    
    private func updateNetworkConfig(_ config: String) throws {
        try serverConfigurationStorage.addConfiguration(fileBase64Content: config, setupAsCurrent: true)
        AnytypeAnalytics.instance().logUploadNetworkConfiguration()
        AnytypeAnalytics.instance().logSelectNetwork(type: .selfHost, route: .deeplink)
    }
}
