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
            tipPerformer = .init(tip: nil)
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
            
            guard let sharingTipView = sharingTipAssembly.make(
                onClose: { [weak self] _ in
                    self?.navigationContext.dismissTopPresented(animated: true)
                },
                onShareURL:  { [weak self] url in
                    self?.shareURL(url: url)
                }
            ) else {
                return
            }
            navigationContext.present(sharingTipView, animated: true)
        }
    }
    
    private func shareURL(url: URL) {
        let activityIndicatorViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        navigationContext.present(activityIndicatorViewController, animated: true, completion: nil)
    }
}
