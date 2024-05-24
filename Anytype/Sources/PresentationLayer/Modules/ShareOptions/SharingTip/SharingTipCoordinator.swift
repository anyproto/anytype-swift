import UIKit

@MainActor
protocol SharingTipCoordinatorProtocol {
    func startObservingTips()
}

@MainActor
final class SharingTipCoordinator: SharingTipCoordinatorProtocol {
    
    private let sharingTipPerformer: UIKitTipPerformer = {
        if #available(iOS 17.0, *) {
            return UIKitTipPerformer(tip: SharingTip())
        } else {
            return UIKitTipPerformer(tip: nil)
        }
    }()
    
    @Injected(\.legacyNavigationContext)
    private var navigationContext: NavigationContextProtocol
    
    nonisolated init() {}
    
    func startObservingTips() {
        sharingTipPerformer.presentHandler = { [weak self] in
            guard #available(iOS 17.0, *) else {
                return
            }
            
            guard let self else { return }
            
            UIApplication.shared.hideKeyboard()
            
            navigationContext.present(SharingTipView())
        }
    }
}
