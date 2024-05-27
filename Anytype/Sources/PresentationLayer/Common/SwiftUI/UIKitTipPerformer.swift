import TipKit
import Combine

final class UIKitTipPerformer {
    var presentHandler: (() -> Void)?
    private let tip: Any?
    private var cancellable: AnyCancellable?
    
    init(tip: Any?) {
        self.tip = tip
        
        if #available(iOS 17.0, *) {
            setupHandlers()
        }
    }
    
    @available(iOS 17.0, *)
    private func setupHandlers() {
        if let tip = tip as? any Tip {
            cancellable = Task { @MainActor [weak self] in
                for await shouldDisplay in tip.shouldDisplayUpdates {
                    if shouldDisplay {
                        self?.presentHandler?()
                    }
                }
            }.cancellable()
        }
    }
}
