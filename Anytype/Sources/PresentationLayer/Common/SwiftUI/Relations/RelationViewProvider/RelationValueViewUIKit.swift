import UIKit
import AnytypeCore


struct RelationValueViewConfiguration: BlockConfiguration {
    typealias View = RelationValueViewUIKit

    let relation: RelationItemModel?
    let style: RelationStyle
    @EquatableNoop private(set) var action: ((RelationItemModel) -> Void)?
}

final class RelationValueViewUIKit: UIView, BlockContentView {
    private var relationView = UIView()

    func update(with configuration: RelationValueViewConfiguration) {
        relationView.removeFromSuperview()

        if let relation = configuration.relation {
            relationView = obtainRelationView(relation, style: configuration.style)

            if configuration.action.isNotNil {
                relationView.addTapGesture { _ in
                    configuration.action?(relation)
                }
            }
        } else {
            relationView = UIView()
        }
        
        addSubview(relationView) {
            $0.pinToSuperview()
        }
    }

    private func obtainRelationView(_ relation: RelationItemModel, style: RelationStyle) -> UIView {
        switch relation {
        case .text(let text):
            return TextRelationFactory.uiKit(value: text.value, hint: relation.hint, style: style)
        case .number(let text):
            return TextRelationFactory.uiKit(value: text.value, hint: relation.hint, style: style)
        case .status(let status):
            return StatusRelationViewUIKit(statusOption: status.values.first, hint: relation.hint, style: style)
        case .date(let date):
            return TextRelationFactory.uiKit(value: date.value?.text, hint: relation.hint, style: style)
        case .object(let object):
            return ObjectListRelationViewUIKit(options: object.selectedObjects, hint: relation.hint, style: style)
        case .checkbox(let checkbox):
            return CheckboxRelationViewUIKit(isChecked: checkbox.value, relationStyle: style)
        case .url(let text):
            return TextRelationFactory.uiKit(value: text.value, hint: relation.hint, style: style)
        case .email(let text):
            return TextRelationFactory.uiKit(value: text.value, hint: relation.hint, style: style)
        case .phone(let text):
            return TextRelationFactory.uiKit(value: text.value, hint: relation.hint, style: style)
        case .tag(let tag):
            return TagRelationViewUIKIt(tags: tag.selectedTags, hint: relation.hint, style: style)
        case .file(let file):
            return FileListRelationViewUIKit(options: file.files, hint: relation.hint, style: style)
        case .unknown(let unknown):
            return RelationPlaceholderViewUIKit(hint: unknown.value, style: style)
        }
    }
    
    override var debugDescription: String {
        super.debugDescription + relationView.debugDescription + "RelationView size: \(relationView.frame), selfSize: \(self.frame)"
    }
}
