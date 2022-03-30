import UIKit

struct SpacerBlockViewModel: SystemContentConfiguationProvider {
    enum SpacerCase: CGFloat {
        case firstRowOffset = 14
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}

    var hashable: AnyHashable {
        [
            usage
        ] as [AnyHashable]
    }

    let indentationLevel = 0
    let usage: SpacerCase

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        SpacerBlockConfiguration(spacerHeight: usage.rawValue)
            .cellBlockConfiguration(indentationSettings: nil)
    }
}

struct SpacerBlockConfiguration: BlockConfiguration {
    typealias View = SpacerBlockView

    let spacerHeight: CGFloat
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
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        heightConstraint.isActive = true
    }

    func update(with configuration: SpacerBlockConfiguration) {
        heightConstraint.constant = configuration.spacerHeight
    }
}
