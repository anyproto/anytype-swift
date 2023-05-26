import UIKit
import Combine
import Services

class DividerBlockContentView: UIView, BlockContentView {
    
    private let dividerView = DividerBlockView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setupView() {
        addSubview(dividerView)
        dividerView.edgesToSuperview()
    }

    func update(with configuration: DividerBlockContentConfiguration) {
        handle(configuration.content.style)
    }

    
    func handle(_ state: BlockDivider.Style) {
        switch state {
        case .line: dividerView.toLineView()
        case .dots: dividerView.toDotsView()
        }
    }
}
