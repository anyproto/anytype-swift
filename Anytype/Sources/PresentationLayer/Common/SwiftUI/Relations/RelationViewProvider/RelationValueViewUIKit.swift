//
//  RelationValueViewUIKit.swift
//  Anytype
//
//  Created by Denis Batvinkin on 08.02.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import UIKit
import AnytypeCore


final class RelationValueViewUIKit: UIView {
    let relation: Relation
    let style: RelationStyle
    let action: ((_ relation: Relation) -> Void)?

    private var relationView = UIView()

    init(relation: Relation, style: RelationStyle, action: ((Relation) -> Void)?) {
        self.relation = relation
        self.style = style
        self.action = action

        super.init(frame: .zero)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        relationView = obtainRelationView(relation, style: style)

        if action.isNotNil && relation.isEditable {
            relationView.addTapGesture { [weak self] _ in
                guard let self = self else { return }

                self.action?(self.relation)
            }

        }

        addSubview(relationView) {
            $0.pinToSuperview()
        }
    }

    private func obtainRelationView(_ relation: Relation, style: RelationStyle) -> UIView {
        switch relation {
        case .text(let text):
            return TextRelationFactory.uiKit(value: text.value, hint: relation.hint, style: style)
        case .number(let text):
            return TextRelationFactory.uiKit(value: text.value, hint: relation.hint, style: style)
        case .status(let status):
            return StatusRelationViewUIKit(statusOption: status.value, hint: relation.hint, style: style)
        case .date(let date):
            return TextRelationFactory.uiKit(value: date.value?.text, hint: relation.hint, style: style)
        case .object(let object):
            return UIView()
//            ObjectRelationView(options: object.selectedObjects, hint: relation.hint, style: style)
        case .checkbox(let checkbox):
            return CheckboxRelationViewUIKit(isChecked: checkbox.value)
        case .url(let text):
            return TextRelationFactory.uiKit(value: text.value, hint: relation.hint, style: style)
        case .email(let text):
            return TextRelationFactory.uiKit(value: text.value, hint: relation.hint, style: style)
        case .phone(let text):
            return TextRelationFactory.uiKit(value: text.value, hint: relation.hint, style: style)
        case .tag(let tag):
            return TagRelationViewUIKIt(tags: tag.selectedTags, hint: relation.hint, style: style)
        case .file(let file):
            return UIView()
//            FileRelationView(options: file.files, hint: relation.hint, style: style)
        case .unknown(let unknown):
            return UIView()
//            RelationsListRowPlaceholderView(hint: unknown.value, type: style.placeholderType)
        }
    }
}
