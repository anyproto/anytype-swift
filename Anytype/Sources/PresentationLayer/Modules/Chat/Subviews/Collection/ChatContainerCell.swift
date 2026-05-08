import UIKit
import SwiftUI

final class ChatContainerCell<Item: Equatable & Hashable, Content: View>: UICollectionViewCell {

    private var item: Item?
    private var builder: ((Item) -> Content)?
    // Skipping rebuilds for transient UICellConfigurationState changes (focus,
    // highlight, trait collection) avoids tearing down UIHostingContentView on
    // every state transition — a known source of weak-store races during fast
    // cell reuse on iOS 18.x.
    private var configuredItem: Item?

    func setItem(_ item: Item, builder: ((Item) -> Content)?) {
        self.item = item
        self.builder = builder
        setNeedsUpdateConfiguration()
    }

    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)

        guard let item, let builder, configuredItem != item else { return }
        configuredItem = item

        // Builder is intentionally reused across SwiftUI update cycles for equal
        // items. Any dynamic state it reads must be captured by reference (class)
        // or via observation, never by value — otherwise the gate above will
        // serve stale data.
        contentConfiguration = UIHostingConfiguration { [item, builder] in
            builder(item)
        }
        .margins(.all, 0)
        .minSize(height: 0)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        configuredItem = nil
    }
}
