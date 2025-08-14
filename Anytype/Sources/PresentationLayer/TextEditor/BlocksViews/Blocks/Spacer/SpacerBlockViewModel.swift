import UIKit

struct SpacerBlockViewModel: SystemContentConfiguationProvider {
    enum SpacerCase: CGFloat {
        case firstRowOffset = 14
        case another = 15
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}

    var hashable: AnyHashable { blockId }
    var blockId: String { "SpacerBlockViewModel" + String(describing: usage) }

    let usage: SpacerCase

    func makeContentConfiguration(maxWidth: CGFloat) -> any UIContentConfiguration {
        SpacerBlockConfiguration(spacerHeight: usage.rawValue)
            .cellBlockConfiguration(
                dragConfiguration: nil,
                styleConfiguration: nil
            )
    }
}

struct SpacerBlockConfiguration: BlockConfiguration {
    typealias View = SpacerBlockView

    let spacerHeight: CGFloat
    
    var contentInsets: UIEdgeInsets { .zero }
}

final class SpacerBlockView: UIView, BlockContentView {
    private lazy var heightConstraint = heightAnchor.constraint(equalToConstant: 10)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .Background.primary
        translatesAutoresizingMaskIntoConstraints = false
        heightConstraint.isActive = true
    }

    func update(with configuration: SpacerBlockConfiguration) {
        heightConstraint.constant = configuration.spacerHeight
    }
}
