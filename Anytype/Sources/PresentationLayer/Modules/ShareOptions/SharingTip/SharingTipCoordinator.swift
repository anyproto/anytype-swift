import UIKit

@MainActor
protocol SharingTipCoordinatorProtocol {
    func startObservingTips()
}

@MainActor
final class SharingTipCoordinator: SharingTipCoordinatorProtocol {
    private var sharingTipPerformer: UIKitTipPerformer
    @Injected(\.legacyNavigationContext)
    private var navigationContext: NavigationContextProtocol
    
    nonisolated init() {
        let tipPerformer: UIKitTipPerformer
        if #available(iOS 17.0, *) {
            tipPerformer = UIKitTipPerformer(tip: SharingTip())
        } else {
            tipPerformer = UIKitTipPerformer(tip: nil)
        }
        
        self.sharingTipPerformer = tipPerformer
    }
    
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
