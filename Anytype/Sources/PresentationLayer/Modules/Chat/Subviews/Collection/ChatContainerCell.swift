import UIKit
import SwiftUI

private final class ChatContainerViewCellModel<Item, Content: View>: ObservableObject {
    @Published var item: Item? = nil
    var itemBuilder: ((Item) -> Content)?
}

private struct ChatContainerViewCell<Item, Content: View>: View {
    
    var model: ChatContainerViewCellModel<Item, Content>
    
    var body: some View {
        if let item = model.item {
            model.itemBuilder?(item)
        }
    }
}

final class ChatContainerCell<Item: Equatable & Hashable, Content: View>: UICollectionViewCell {
    
    private let viewModel = ChatContainerViewCellModel<Item, Content>()
    private var item: Item?
    private var builder: ((Item) -> Content)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentConfiguration = UIHostingConfiguration { [viewModel] in
            ChatContainerViewCell(model: viewModel)
        }
        .margins(.all, 0)
        .minSize(height: 0)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setItem(_ item: Item, builder: ((Item) -> Content)?) {
        self.item = item
        self.builder = builder
        setNeedsUpdateConfiguration()
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        viewModel.itemBuilder = builder
        if let item {
            viewModel.item = item
        }
    }
}
