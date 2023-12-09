import UIKit

protocol SharingTipCoordinatorProtocol {
    func startObservingTips()
}

final class SharingTipCoordinator: SharingTipCoordinatorProtocol {
    private let sharingTipAssembly: SharingTipModuleAssemblyProtocol
    private var sharingTipPerformer: UIKitTipPerformer
    private let navigationContext: NavigationContextProtocol
    
    init(
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
    
    @MainActor
    func startObservingTips() {
        sharingTipPerformer.presentHandler = { [weak self] in
            guard #available(iOS 17.0, *) else {
                return
            }
            UIApplication.shared.hideKeyboard()
            
            guard let sharingTipView = self?.sharingTipAssembly.make(
                onClose: { [weak self] _ in
                    self?.navigationContext.dismissTopPresented(animated: true)
                },
                onShareURL:  { [weak self] url in
                    self?.navigationContext.dismissTopPresented(animated: true) {
                        self?.shareURL(url: url)
                    }
                }
            ) else {
                return
            }
            self?.navigationContext.present(sharingTipView, animated: true)
        }
    }
    
    private func shareURL(url: URL) {
        let activityIndicatorViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        navigationContext.present(activityIndicatorViewController, animated: true, completion: nil)
    }
}
