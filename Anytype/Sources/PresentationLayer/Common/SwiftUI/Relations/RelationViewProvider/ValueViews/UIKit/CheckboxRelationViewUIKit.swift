//
//  CheckboxRelationViewUIKit.swift
//  Anytype
//
//  Created by Denis Batvinkin on 10.02.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import UIKit

final class CheckboxRelationViewUIKit: UIView {
    let isChecked: Bool

    private var checkboxView: UIButton!


    // MARK: - Lifecycle

    init(isChecked: Bool) {
        self.isChecked = isChecked

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
            $0.pinToSuperview()
            $0.size(CGSize(width: 18, height: 18))
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
