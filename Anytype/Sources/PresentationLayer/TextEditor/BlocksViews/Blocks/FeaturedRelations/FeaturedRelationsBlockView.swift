import Foundation
import UIKit

final class FeaturedRelationsBlockView: UIView, UIContentView {
        
    // MARK: - Views
    
    private let typeLabel: AnytypeLabel = {
        let label = AnytypeLabel(style: .relation2Regular)
        label.textColor = .textSecondary
        return label
    }()
    
    // MARK: - Private variables
    
    private var appliedConfiguration: FeaturedRelationsBlockContentConfiguration!
    
    // MARK: - Internal variables
    
    var configuration: UIContentConfiguration {
        get { self.appliedConfiguration }
        set {
            guard
                let configuration = newValue as? FeaturedRelationsBlockContentConfiguration,
                appliedConfiguration != configuration
            else {
                return
            }
            
            apply(configuration)
        }
    }
    
    // MARK: - Initializers
    
    init(configuration: FeaturedRelationsBlockContentConfiguration) {
        super.init(frame: .zero)
        
        setupLayout()
        apply(configuration)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        appliedConfiguration = configuration
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
