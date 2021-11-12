import Foundation
import UIKit

final class FeaturedRelationsBlockView: BaseBlockView<FeaturedRelationsBlockContentConfiguration> {
        
    // MARK: - Views
    
    private let typeLabel: AnytypeLabel = {
        let label = AnytypeLabel(style: .relation2Regular)
        label.textColor = .textSecondary
        return label
    }()
    
    // MARK: - Private variables

    override func update(with configuration: FeaturedRelationsBlockContentConfiguration) {
        super.update(with: configuration)

        apply(configuration)
    }

    override func setupSubviews() {
        super.setupSubviews()
        setupLayout()
    }
    
}

private extension FeaturedRelationsBlockView  {
    
    func setupLayout() {
        addSubview(typeLabel) {
            $0.pinToSuperview(
                insets: UIEdgeInsets(
                    top: Constants.verticalSpacing,
                    left: Constants.horizontalSpacing,
                    bottom: -Constants.verticalSpacing,
                    right: -Constants.horizontalSpacing
                )
            )
        }
    }
    
    func apply(_ configuration: FeaturedRelationsBlockContentConfiguration) {
        typeLabel.setText(configuration.type)
        typeLabel.textAlignment = configuration.alignment
    }
    
}

private extension FeaturedRelationsBlockView {
    
    enum Constants {
        static let horizontalSpacing: CGFloat = 20
        static let verticalSpacing: CGFloat = 8
    }
}
