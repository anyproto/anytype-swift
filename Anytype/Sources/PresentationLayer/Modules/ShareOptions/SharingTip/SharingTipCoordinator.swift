import UIKit

@MainActor
protocol SharingTipCoordinatorProtocol {
    func startObservingTips()
}

@MainActor
final class SharingTipCoordinator: SharingTipCoordinatorProtocol {
    private var sharingTipPerformer: UIKitTipPerformer
    private let navigationContext: NavigationContextProtocol
    
    nonisolated init(
        navigationContext: NavigationContextProtocol
    ) {
        let tipPerformer: UIKitTipPerformer
        if #available(iOS 17.0, *) {
            tipPerformer = UIKitTipPerformer(tip: SharingTip())
        } else {
            tipPerformer = UIKitTipPerformer(tip: nil)
        }
        
        self.sharingTipPerformer = tipPerformer
        self.navigationContext = navigationContext
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
