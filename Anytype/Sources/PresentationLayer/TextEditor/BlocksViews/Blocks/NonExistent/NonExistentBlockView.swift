import Combine
import BlocksModels
import UIKit
import AnytypeCore

final class NonExistentBlockView: UIView, BlockContentView {
    
    private enum Constants {
        static let contentHeight = 32.0
        static let iconSize = 18.0
        static let sideSpacing = 3.0
        static let innerSpacing = 9.0
    }
    
    // MARK: - Private properties
    
    private let label: AnytypeLabel = {
        let label = AnytypeLabel(style: .uxBodyRegular)
        label.textColor = .textTertiary
        return label
    }()

    private let icon: UIImageView = {
        let imageView = UIImageView(asset: .ghost)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - BlockContentView
    
    func update(with configuration: NonExistentBlockContentConfiguration) {
        label.setText(configuration.text)
    }

    // MARK: - Private
    
    private func setup() {
        
        layoutUsing.stack {
            $0.alignment = .center
            $0.layoutUsing.anchors {
                $0.pinToSuperview()
                $0.height.equal(to: Constants.contentHeight)
            }
        } builder: {
            $0.hStack(
                $0.hGap(fixed: Constants.sideSpacing),
                icon,
                $0.hGap(fixed: Constants.innerSpacing),
                label,
                $0.hGap(min: Constants.sideSpacing)
            )
        }
        
        icon.layoutUsing.anchors {
            $0.height.equal(to: Constants.iconSize)
            $0.width.equal(to: Constants.iconSize)
        }
    }
}
