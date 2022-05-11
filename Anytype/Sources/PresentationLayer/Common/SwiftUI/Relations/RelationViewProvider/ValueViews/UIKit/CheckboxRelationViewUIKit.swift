//
//  CheckboxRelationViewUIKit.swift
//  Anytype
//
//  Created by Denis Batvinkin on 10.02.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import UIKit

final class CheckboxRelationViewUIKit: UIView {
    
    private var checkboxView: UIButton!
    
    private let isChecked: Bool
    private let relationStyle: RelationStyle

    // MARK: - Lifecycle

    init(isChecked: Bool, relationStyle: RelationStyle) {
        self.isChecked = isChecked
        self.relationStyle = relationStyle
        
        super.init(frame: .zero)

        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup view

    private func setupViews() {
        isUserInteractionEnabled = true
        checkboxView = createCheckboxView()

        addSubview(checkboxView) {
            $0.pinToSuperview(excluding: [.right])
            $0.size(relationStyle.checkboxSize)
        }
    }

    private func createCheckboxView() -> UIButton {
        let checkboxView = UIButton()
        checkboxView.isUserInteractionEnabled = false
        checkboxView.setImage(UIImage.Relations.checkboxUnchecked, for: .normal)
        checkboxView.setImage(UIImage.Relations.checkboxChecked, for: .selected)
        checkboxView.contentMode = .center
        checkboxView.isSelected = isChecked

        return checkboxView
    }
}
