import UIKit

class OurContextMenuInteraction: UIContextMenuInteraction {
    /// Uncomment later if needed.
    /// Also, you should update delegate by `update(delegate:)` when view apply(configuration:) method has been called.
    typealias Delegate = UIContextMenuInteractionDelegate

    class ProxyChain: NSObject, Delegate {
        private var delegate: Delegate?
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            self.delegate?.contextMenuInteraction(interaction, configurationForMenuAtLocation: location)
        }
        func update(_ delegate: Delegate?) {
            self.delegate = delegate
        }
    }

    /// Proxy
    private var proxyChain: ProxyChain = .init()
    private var ourDelegate: Delegate { self.proxyChain }

    /// Initialization
    override init(delegate: Delegate) {
        self.proxyChain.update(delegate)
        super.init(delegate: self.proxyChain)
    }

    func update(delegate: Delegate) {
        self.proxyChain.update(delegate)
    }

    /// UIContextMenuInteractionDelegate
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        self.ourDelegate.contextMenuInteraction(interaction, configurationForMenuAtLocation: location)
    }
}
