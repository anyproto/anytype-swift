import UIKit
import AnytypeCore

struct RelationValueViewConfiguration: BlockConfiguration {
    typealias View = RelationValueViewUIKit

    let relation: RelationItemModel?
    let style: RelationStyle
    @EquatableNoop private(set) var action: (() -> Void)?
}

final class RelationValueViewUIKit: UIView, BlockContentView {
    private var relationView = UIView()

    func update(with configuration: RelationValueViewConfiguration) {
        relationView.removeFromSuperview()
        
        let model = RelationValueViewModel(
            relation: configuration.relation,
            style: configuration.style,
            mode: .button(action: configuration.action),
            leftAlign: true
        )
        relationView = RelationValueView(model: model).asUIView()
        
        addSubview(relationView) {
            $0.pinToSuperview()
        }
    }
}
