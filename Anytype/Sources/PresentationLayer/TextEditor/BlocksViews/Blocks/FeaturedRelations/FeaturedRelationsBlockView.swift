import Foundation
import UIKit
import SwiftUI

final class FeaturedRelationsBlockView: UIView, BlockContentView {
    // MARK: - Views

    private var relationsView: UIView?

    private var relationFlowViewModel: FlowRelationsViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    func update(with configuration: FeaturedRelationsBlockContentConfiguration) {
        apply(configuration)
    }

    func update(with state: UICellConfigurationState) {
        relationsView?.isUserInteractionEnabled = !state.isLocked
    }
}

private extension FeaturedRelationsBlockView  {
    
    func setupLayout() {}
    
    func apply(_ configuration: FeaturedRelationsBlockContentConfiguration) {
        if relationsView == nil {
            let relationFlowViewModel = FlowRelationsViewModel(
                relations: configuration.featuredRelations,
                onRelationTap: configuration.onRelationTap
            )
            self.relationFlowViewModel = relationFlowViewModel
            relationFlowViewModel.relations = configuration.featuredRelations
            relationFlowViewModel.alignment = configuration.alignment.asSwiftUI

            let relationsView = FlowRelationsView(viewModel: relationFlowViewModel).asUIView()

            addSubview(relationsView) {
                $0.leading.equal(to: leadingAnchor, constant: Constants.horizontalSpacing)
                $0.top.equal(to: topAnchor, constant: Constants.verticalSpacing)
                $0.bottom.equal(to: bottomAnchor, constant: -Constants.verticalSpacing)
                $0.trailing.equal(to: trailingAnchor, constant: -Constants.horizontalSpacing)
            }

            self.relationsView = relationsView
        }

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
