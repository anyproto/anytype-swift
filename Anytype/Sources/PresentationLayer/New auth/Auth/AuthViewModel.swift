import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published var showJoinFlow: Bool = false
    @Published var showSafari: Bool = false
    @Published var opacity: Double = 1
    
    var currentUrl: URL?
    
    // MARK: - Private
    
    private let viewControllerProvider: ViewControllerProviderProtocol
    private weak var output: AuthViewModelOutput?
    
    init(
        viewControllerProvider: ViewControllerProviderProtocol,
        output: AuthViewModelOutput?
    ) {
        self.viewControllerProvider = viewControllerProvider
        self.output = output
    }
    
    // MARK: - Public
    
    func onViewAppear() {
        viewControllerProvider.window?.overrideUserInterfaceStyle = .dark
        changeContentOpacity(false)
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
    
    func onUrlTapAction(_ url: URL) {
        currentUrl = url
        showSafari.toggle()
    }
    
    private func changeContentOpacity(_ hide: Bool) {
        withAnimation(.fastSpring) {
            opacity = hide ? 0 : 1
        }
    }
}
