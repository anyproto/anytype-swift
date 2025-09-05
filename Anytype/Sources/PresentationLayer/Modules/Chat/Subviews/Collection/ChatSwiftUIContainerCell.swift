import UIKit
import SwiftUI

final class ChatSwiftUIContainerCell<Item: Equatable & Hashable, Content: View>: UICollectionViewCell {
    
    private var item: Item?
    private var builder: ((Item) -> Content)?
    
    func setView(_ item: Item, builder: ((Item) -> Content)?) {
        self.item = item
        self.builder = builder
        setNeedsUpdateConfiguration()
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        
        if let item, let builder {
            contentConfiguration = UIHostingConfiguration { [item, builder] in
                builder(item)
            }
            .margins(.all, 0)
            .minSize(height: 0)
        }
    }
}
