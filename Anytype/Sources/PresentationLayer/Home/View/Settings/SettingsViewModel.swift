import SwiftUI
import ProtobufMessages
import AnytypeCore
import Combine

final class SettingsViewModel: ObservableObject {
    
    @Published var loggingOut = false
    @Published var accountDeleting = false
    @Published var wallpaperPicker = false
    @Published var keychain = false
    @Published var pincode = false
    @Published var defaultType = false
    @Published var clearCacheAlert = false
    @Published var clearCacheSuccessful = false
    @Published var about = false
    @Published var appearance = false
    @Published var account = false
    @Published var personalization = false
    @Published var debugMenu = false
    @Published var currentStyle = UserDefaultsConfig.userInterfaceStyle {
        didSet {
            UserDefaultsConfig.userInterfaceStyle = currentStyle
            UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = currentStyle
        }
    }
    
    @Published var wallpaper: BackgroundType = UserDefaultsConfig.wallpaper {
        didSet {
            UserDefaultsConfig.wallpaper = wallpaper
        }
    }
        
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func logout(removeData: Bool) {
        authService.logout(removeData: removeData) { isSuccess in
            guard isSuccess else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
            
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            WindowManager.shared.showAuthWindow()
        }
    }
    
    func accountDeletionConfirm() {
        guard let status = authService.deleteAccount() else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        
        switch status {
        case .active:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        case .pendingDeletion(let progress):
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            WindowManager.shared.showDeletedAccountWindow(progress: progress)
        case .deleted:
            logout(removeData: true)
        }
        
    }
    
    private var clearCacheSubscription: AnyCancellable?
    func clearCache(completion: @escaping (Bool) -> ()) {
        clearCacheSubscription = Anytype_Rpc.FileList.Offload.Service.invoke(
            onlyIds: [], includeNotPinned: false, queue: DispatchQueue.global(qos: .userInitiated)
        )
            .receiveOnMain()
            .sinkWithResult { result in
                switch result {
                case .failure(let error):
                    anytypeAssertionFailure("Clear cache error: \(error)", domain: .clearCache)
                    completion(false)
                case .success:
                    completion(true)

                    AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.fileCacheCleared)
                }
            }
    }
}

extension UIUserInterfaceStyle: Identifiable {
    public var id: Int { rawValue }

    static var allCases: [UIUserInterfaceStyle] { [.light, .dark, .unspecified,] }

    var title: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case .unspecified:
            fallthrough
        @unknown default:
            return "System"
        }
    }

    var image: UIImage {
        switch self {
        case .light:
            return UIImage(imageLiteralResourceName: "theme_light")
        case .dark:
            return UIImage(imageLiteralResourceName: "theme_dark")
        case .unspecified:
            fallthrough
        @unknown default:
            return UIImage(imageLiteralResourceName: "theme_system")
        }
    }
}
