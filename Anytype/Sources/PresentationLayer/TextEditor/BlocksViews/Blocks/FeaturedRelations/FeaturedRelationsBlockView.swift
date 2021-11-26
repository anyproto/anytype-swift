import Foundation
import UIKit
import SwiftUI

final class FeaturedRelationsBlockView: BaseBlockView<FeaturedRelationsBlockContentConfiguration> {

    // MARK: - Views

    private lazy var relationsView: UIView = {
        return UIView()
    }()

    private var relationFlowViewModel: FlowRelationsViewModel?
    
    // MARK: - BaseBlockView

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
        let relationFlowViewModel = FlowRelationsViewModel(
            relations: currentConfiguration.featuredRelations,
            onRelationTap: currentConfiguration.onRelationTap
        )
        self.relationFlowViewModel = relationFlowViewModel
        relationFlowViewModel.relations = currentConfiguration.featuredRelations
        relationFlowViewModel.alignment = currentConfiguration.alignment.asSwiftUI

        let relationsView = FlowRelationsView(viewModel: relationFlowViewModel).asUIView()

        addSubview(relationsView) {
            $0.leading.equal(to: leadingAnchor, constant: Constants.horizontalSpacing)
            $0.top.equal(to: topAnchor, constant: Constants.verticalSpacing)
            $0.bottom.equal(to: bottomAnchor, constant: -Constants.verticalSpacing)
            $0.trailing.equal(to: trailingAnchor, constant: -Constants.horizontalSpacing)
        }
    }
    
    func apply(_ configuration: FeaturedRelationsBlockContentConfiguration) {
        relationFlowViewModel?.relations = configuration.featuredRelations
        relationFlowViewModel?.alignment = configuration.alignment.asSwiftUI
    }
}

private extension FeaturedRelationsBlockView {
    
    enum Constants {
        static let horizontalSpacing: CGFloat = 20
        static let verticalSpacing: CGFloat = 8
    }
}
