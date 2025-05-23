import UIKit
import AnytypeCore

struct PropertyValueViewConfiguration: BlockConfiguration {
    typealias View = PropertyValueViewUIKit

    let property: PropertyItemModel?
    let style: PropertyStyle
    @EquatableNoop private(set) var action: (() -> Void)?
}

final class PropertyValueViewUIKit: UIView, BlockContentView {
    private var relationView = UIView()

    func update(with configuration: PropertyValueViewConfiguration) {
        relationView.removeFromSuperview()
        
        let model = PropertyValueViewModel(
            property: configuration.property,
            style: configuration.style,
            mode: .button(action: configuration.action),
            leftAlign: true
        )
        relationView = PropertyValueView(model: model).asUIView()
        
        addSubview(relationView) {
            $0.pinToSuperview()
        }
    }
}
