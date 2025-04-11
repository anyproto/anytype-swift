import SwiftUI
import Combine
import Services
import DeepLinks

enum AuthViewModelError: Error {
    case unsupportedAppAction
}

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published var showJoinFlow: Bool = false
    @Published var showLoginFlow: Bool = false
    @Published var showDebugMenu: Bool = false
    @Published var showSettings: Bool = false
    @Published var inProgress = false
    @Published var opacity: Double = 1
    @Published var errorText: String? {
        didSet { showError = errorText.isNotNil }
    }
    @Published var showError: Bool = false
    
    // MARK: - State
    private let state = JoinFlowState()
    
    // MARK: - Private
    private weak var output: (any AuthViewModelOutput)?
    
    @Injected(\.serverConfigurationStorage)
    private var serverConfigurationStorage: any ServerConfigurationStorageProtocol
    @Injected(\.appActionStorage)
    private var appActionsStorage: AppActionStorage
    @Injected(\.authService)
    private var authService: any AuthServiceProtocol
    @Injected(\.seedService)
    private var seedService: any SeedServiceProtocol
    @Injected(\.usecaseService)
    private var usecaseService: any UsecaseServiceProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    
    private var subscription: AnyCancellable?
    
    init(output: (any AuthViewModelOutput)?) {
        self.output = output
    }
    
    // MARK: - Public
    
    func onAppear() {
        changeContentOpacity(false)
        startSubscriptions()
        AnytypeAnalytics.instance().logMainAuthScreenShow()
    }
    
    private func startSubscriptions() {
        subscription = appActionsStorage.$action.receiveOnMain().sink { [weak self] action in
            guard let action, let self else { return }
            
            if (try? handleAppAction(action: action)).isNotNil {
                appActionsStorage.action = nil
            }
        }
    }
    
    func videoUrl() -> URL? {
        guard let url = Bundle.main.url(forResource: "anytype-shader-S", withExtension: "mp4") else {
            return nil
        }
        return url
    }
    
    func onJoinButtonTap() {
        if state.mnemonic.isEmpty {
            createAccount()
        } else {
            onSuccess()
        }
    }
    
    func onJoinAction() -> AnyView? {
        output?.onJoinAction(state: state)
    }
    
    func onLoginButtonTap() {
        showLoginFlow.toggle()
        changeContentOpacity(true)
    }
    
    func onLoginAction() -> AnyView? {
        output?.onLoginAction()
    }
    
    func onSettingsButtonTap() {
        showSettings.toggle()
    }
    
    func onSettingsAction() -> AnyView? {
        return output?.onSettingsAction()
    }
    
    // MARK: - Create account step
    
    private func createAccount() {
        Task {
            AnytypeAnalytics.instance().logStartCreateAccount()
            inProgress = true
            
            do {
                state.mnemonic = try await authService.createWallet()
                let iconOption = IconColorStorage.randomOption()
                let account = try await authService.createAccount(
                    name: state.soul,
                    iconOption: iconOption,
                    imagePath: ""
                )
                try await setDefaultSpaceInfo(account.info.accountSpaceId, iconOption: iconOption)
                try? seedService.saveSeed(state.mnemonic)
                
                onSuccess()
            } catch {
                createAccountError(error)
            }
        }
    }
    
    private func setDefaultSpaceInfo(_ spaceId: String, iconOption: Int) async throws {
        guard spaceId.isNotEmpty else { return }
        let startingObjectId = try? await usecaseService.setObjectImportDefaultUseCase(spaceId: spaceId)
        if let startingObjectId, startingObjectId.isNotEmpty, appActionsStorage.action.isNil {
            appActionsStorage.action = .startObject(objectId: startingObjectId, spaceId: spaceId)
        }
        try? await workspaceService.workspaceSetDetails(
            spaceId: spaceId,
            details: [.name(Loc.myFirstSpace), .iconOption(iconOption)]
        )
    }
    
    private func onSuccess() {
        inProgress = false
        showJoinFlow.toggle()
        changeContentOpacity(true)
    }
    
    private func createAccountError(_ error: some Error) {
        inProgress = false
        errorText = error.localizedDescription
    }
    
    private func changeContentOpacity(_ hide: Bool) {
        withAnimation(.fastSpring) {
            opacity = hide ? 0 : 1
        }
    }
    
    private func handleAppAction(action: AppAction) throws {
        switch action {
        case .createObjectFromQuickAction, .startObject:
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
