import SwiftUI
import Combine
import Services
import AnytypeCore

@MainActor
final class PrimaryAuthViewModel: ObservableObject {
    
    @Published var createAccountTaskId: String?
    @Published var inProgress = false
    @Published var errorText: String? {
        didSet { showError = errorText.isNotNil }
    }
    @Published var showError: Bool = false
    
    // MARK: - State
    private let state = JoinFlowState()
    
    // MARK: - Private
    private weak var output: (any PrimaryAuthOutput)?
    
    @Injected(\.serverConfigurationStorage)
    private var serverConfigurationStorage: any ServerConfigurationStorageProtocol
    @Injected(\.appActionStorage)
    private var appActionStorage: AppActionStorage
    @Injected(\.authService)
    private var authService: any AuthServiceProtocol
    @Injected(\.seedService)
    private var seedService: any SeedServiceProtocol
    @Injected(\.usecaseService)
    private var usecaseService: any UsecaseServiceProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.pushNotificationsPermissionService)
    private var pushNotificationsPermissionService: any PushNotificationsPermissionServiceProtocol
    
    private var subscription: AnyCancellable?
    
    init(output: (any PrimaryAuthOutput)?) {
        self.output = output
    }
    
    // MARK: - Public
    
    func onAppear() {
        startSubscriptions()
        AnytypeAnalytics.instance().logMainAuthScreenShow()
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
    
    // MARK: - Private
    
    private func startSubscriptions() {
        subscription = appActionStorage.$action.receiveOnMain().sink { [weak self] action in
            guard let action, let self else { return }
            
            if (try? handleAppAction(action: action)).isNotNil {
                appActionStorage.action = nil
            }
        }
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
        let startingObjectId = try? await usecaseService.setObjectImportDefaultUseCase(spaceId: spaceId)
        if !FeatureFlags.turnOffAutomaticWidgetOpening, let startingObjectId, startingObjectId.isNotEmpty, appActionStorage.action.isNil {
            appActionStorage.action = .openObject(objectId: startingObjectId, spaceId: spaceId)
        }
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
            case .createObjectFromWidget, .showSharingExtension, .galleryImport, .invite, .object, .membership:
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
