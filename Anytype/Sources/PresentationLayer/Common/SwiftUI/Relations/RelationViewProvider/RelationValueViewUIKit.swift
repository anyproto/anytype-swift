import UIKit
import AnytypeCore

struct RelationValueViewConfiguration: BlockConfiguration {
    typealias View = RelationValueViewUIKit

    let relation: RelationItemModel?
    let style: RelationStyle
    @EquatableNoop private(set) var action: (() -> Void)?
}

final class RelationValueViewUIKit: UIView, BlockContentView {
    private let relationView: UIView
    private let relationModel: RelationValueViewModel
    
    override init(frame: CGRect) {
        let model = RelationValueViewModel()
        relationModel = model
        relationView = RelationValueView(model: model).asUIView()

        super.init(frame: frame)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(relationView) {
            $0.pinToSuperview()
        }
    }

    func update(with configuration: RelationValueViewConfiguration) {
        relationModel.updateData(
            RelationValueViewData(
                relation: configuration.relation,
                style: configuration.style,
                mode: .button(action: configuration.action),
                leftAlign: true
            )
        )
    }
}
