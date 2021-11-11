import UIKit

private enum Constants {
    static let selectionViewInset: UIEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: -8)
}

class BaseBlockView<Configuration: AnytypeBlockContentConfigurationProtocol>: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfiguration = newValue as? Configuration else { return }

            currentConfiguration = newConfiguration

        }
    }
    var currentConfiguration: Configuration {
        didSet { update(with: currentConfiguration) }
    }

    private let selectionView = BaseSelectionView()

    init(configuration: Configuration) {
        self.currentConfiguration = configuration

        super.init(frame: .zero)

        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with configuration: Configuration) {
        configuration.currentConfigurationState.map(update(with:))
    }

    func update(with state: UICellConfigurationState) {
        selectionView.updateStyle(isSelected: state.isSelected)
    }
    

    func setupSubviews() {
        addSubview(selectionView) {
            $0.pinToSuperview(insets: Constants.selectionViewInset)
        }
    }
}

private final class BaseSelectionView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 6
        layer.cornerCurve = .continuous
        isUserInteractionEnabled = false
        clipsToBounds = true
    }

    func updateStyle(isSelected: Bool) {
        if isSelected {
            layer.borderWidth = 2.0
            layer.borderColor = UIColor.pureAmber.cgColor
            backgroundColor = UIColor.pureAmber.withAlphaComponent(0.1)
        } else {
            layer.borderWidth = 0.0
            layer.borderColor = nil
            backgroundColor = .clear
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
