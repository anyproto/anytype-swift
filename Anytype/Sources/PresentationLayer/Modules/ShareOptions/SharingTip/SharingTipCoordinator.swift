import UIKit

@MainActor
protocol SharingTipCoordinatorProtocol {
    func startObservingTips()
}

@MainActor
final class SharingTipCoordinator: SharingTipCoordinatorProtocol {
    private let sharingTipAssembly: SharingTipModuleAssemblyProtocol
    private var sharingTipPerformer: UIKitTipPerformer
    private let navigationContext: NavigationContextProtocol
    
    nonisolated init(
        sharingTipAssembly: SharingTipModuleAssemblyProtocol,
        navigationContext: NavigationContextProtocol
    ) {
        let tipPerformer: UIKitTipPerformer
        if #available(iOS 17.0, *) {
            tipPerformer = UIKitTipPerformer(tip: SharingTip())
        } else {
            tipPerformer = UIKitTipPerformer(tip: nil)
        }
        
        self.sharingTipAssembly = sharingTipAssembly
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
            
            let sharingTipView = sharingTipAssembly.make()
            navigationContext.present(sharingTipView, animated: true)
        }
    }
}
