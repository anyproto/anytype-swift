import UIKit
import Combine
import BlocksModels

class DividerBlockContentView: BaseBlockView<DividerBlockContentConfiguration> {
    
    private let dividerView = DividerBlockView()

    override func setupSubviews() {
        super.setupSubviews()

        addSubview(dividerView)
        dividerView.edgesToSuperview()
    }

    override func update(with configuration: DividerBlockContentConfiguration) {
        super.update(with: configuration)

        handle(currentConfiguration.content.style)
    }

    
    func handle(_ state: BlockDivider.Style) {
        switch state {
        case .line: dividerView.toLineView()
        case .dots: dividerView.toDotsView()
        }
    }
}
