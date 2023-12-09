import TipKit

final class UIKitTipPerformer {
    var presentHandler: (() -> Void)?
    private let tip: Any?
    
    init(tip: Any?) {
        self.tip = tip
        
        if #available(iOS 17.0, *) {
            setupHandlers()
        }
    }
    
    @available(iOS 17.0, *)
    private func setupHandlers() {
        if let tip = tip as? any Tip {
            Task { @MainActor in
                for await shouldDisplay in tip.shouldDisplayUpdates {
                    if shouldDisplay {
                        presentHandler?()
                    }
                }
            }
        }
    }
}
