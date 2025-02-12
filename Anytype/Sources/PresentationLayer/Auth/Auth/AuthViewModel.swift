import SwiftUI
import Combine


enum AuthViewModelError: Error {
    case unsupportedAppAction
}

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published var showJoinFlow: Bool = false
    @Published var showLoginFlow: Bool = false
    @Published var showDebugMenu: Bool = false
    @Published var showSettings: Bool = false
    @Published var opacity: Double = 1
    
    // MARK: - Private
    private weak var output: (any AuthViewModelOutput)?
    
    @Injected(\.serverConfigurationStorage)
    private var serverConfigurationStorage: any ServerConfigurationStorageProtocol
    @Injected(\.appActionStorage)
    private var appActionsStorage: AppActionStorage
    
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
        showJoinFlow.toggle()
        changeContentOpacity(true)
    }
    
    func onJoinAction() -> AnyView? {
        output?.onJoinAction()
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
    
    private func changeContentOpacity(_ hide: Bool) {
        withAnimation(.fastSpring) {
            opacity = hide ? 0 : 1
        }
    }
    
    private func handleAppAction(action: AppAction) throws {
        switch action {
        case .createObjectFromQuickAction:
            throw AuthViewModelError.unsupportedAppAction
        case .deepLink(let deeplink):
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
