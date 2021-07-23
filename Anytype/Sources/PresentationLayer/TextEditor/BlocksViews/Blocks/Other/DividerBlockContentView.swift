import UIKit
import Combine
import BlocksModels

class DividerBlockContentView: UIView & UIContentView {
    
    private let dividerView = DividerBlockView()
            
    // MARK: Setup
    func setup() {
        addSubview(dividerView)
        dividerView.edgesToSuperview()
    }
    
    func handle(_ state: BlockDivider.Style) {
        switch state {
        case .line: dividerView.toLineView()
        case .dots: dividerView.toDotsView()
        }
    }
    
    /// Initialization
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var currentConfiguration: DividerBlockContentConfiguration!
    var configuration: UIContentConfiguration {
        get { self.currentConfiguration }
        set {
            /// apply configuration
            guard let configuration = newValue as? DividerBlockContentConfiguration else { return }
            self.apply(configuration: configuration)
        }
    }

    init(configuration: DividerBlockContentConfiguration) {
        super.init(frame: .zero)
        self.setup()
        self.apply(configuration: configuration)
    }
    
    private func apply(configuration: DividerBlockContentConfiguration) {
        guard self.currentConfiguration != configuration else {
            return
        }
        
        self.currentConfiguration = configuration
        handle(currentConfiguration.content.style)
    }
}
