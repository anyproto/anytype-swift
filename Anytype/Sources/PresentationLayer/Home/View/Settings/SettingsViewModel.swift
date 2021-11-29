import SwiftUI
import ProtobufMessages
import AnytypeCore
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var loggingOut = false
    @Published var wallpaperPicker = false
    @Published var keychain = false
    @Published var pincode = false
    @Published var other = false
    @Published var defaultType = false
    @Published var clearCacheAlert = false
    @Published var clearCacheSuccessful = false
    @Published var about = false
    @Published var debugMenu = false
    @Published var loadingAlert = LoadingAlertData.empty
    
    @Published var wallpaper: BackgroundType = UserDefaultsConfig.wallpaper {
        didSet {
            UserDefaultsConfig.wallpaper = wallpaper
        }
    }
    
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func logout() {
        authService.logout()
        windowHolder?.startNewRootView(MainAuthView(viewModel: MainAuthViewModel()))
    }
    
    private var clearCacheSubscription: AnyCancellable?
    func clearCache(completion: @escaping (Bool) -> ()) {
        clearCacheSubscription = Anytype_Rpc.FileList.Offload.Service.invoke(
            onlyIds: [], includeNotPinned: false, queue: DispatchQueue.global(qos: .userInitiated)
        )
            .receiveOnMain()
            .sink(
                receiveCompletion: { sinkCompletion in
                    switch sinkCompletion {
                    case .finished: return
                    case let .failure(error):
                        anytypeAssertionFailure("Clear cache error: \(error)", domain: .clearCache)
                        completion(false)
                    }
                },
                receiveValue: { _ in
                    completion(true)
                }
            )
    }
}
