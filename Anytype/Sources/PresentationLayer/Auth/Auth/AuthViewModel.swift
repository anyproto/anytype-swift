import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published var showJoinFlow: Bool = false
    @Published var showLoginFlow: Bool = false
    @Published var showDebugMenu: Bool = false
    @Published var showSettings: Bool = false
    @Published var opacity: Double = 1
    
    // MARK: - Private
    private weak var output: AuthViewModelOutput?
    
    init(output: AuthViewModelOutput?) {
        self.output = output
    }
    
    // MARK: - Public
    
    func onAppear() {
        changeContentOpacity(false)
        AnytypeAnalytics.instance().logMainAuthScreenShow()
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
    
    func onUrlTapAction(_ url: URL) {
        output?.onUrlAction(url)
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
}
