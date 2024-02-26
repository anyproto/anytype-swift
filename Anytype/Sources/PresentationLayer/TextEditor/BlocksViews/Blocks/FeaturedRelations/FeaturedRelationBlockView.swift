import Foundation
import UIKit
import SwiftUI

final class FeaturedRelationBlockView: UIView, BlockContentView {
    private let featuredRelationsView: UIView
    private let relationsModel: EditorFeaturedRelationsViewModel

    override var intrinsicContentSize: CGSize {
        featuredRelationsView.intrinsicContentSize
    }
    
    override init(frame: CGRect) {
        let model = EditorFeaturedRelationsViewModel()
        relationsModel = model
        featuredRelationsView = EditorFeaturedRelationsView(model: model).asUIView()
        
        super.init(frame: frame)
        
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with configuration: FeaturedRelationsBlockContentConfiguration) {
        relationsModel.updateRelations(configuration.featuredRelations)
        relationsModel.onRelationTap = configuration.onRelationTap
        
        featuredRelationsView.setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    private func setupLayout() {
        addSubview(featuredRelationsView) {
            $0.pinToSuperview(
                insets: .init(top: 8, left: 0, bottom: 0, right: 0)
            )
        }
    }
}
