//
//  EditorNavigationBarTitleView.swift
//  EditorNavigationBarTitleView
//
//  Created by Konstantin Mordan on 18.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

final class EditorNavigationBarTitleView: UIView {
    
    private let stackView = UIStackView()
    
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EditorNavigationBarTitleView: ConfigurableView {
    
    enum Icon {
        case objectIcon(ObjectIcon)
        case todo(Bool)
    }
    
    struct Model {
        let icon: Icon?
        let title: String
    }
    
    func configure(model: Model) {
        titleLabel.text = model.title
        
        switch model.icon {
        case .objectIcon:
            // TODO: - implement
            iconImageView.image = nil
            iconImageView.isHidden = false
            break
        case .todo(let isChecked):
            iconImageView.isHidden = false
            iconImageView.image = isChecked ?
            UIImage.Title.TodoLayout.checkmark :
            UIImage.Title.TodoLayout.checkbox
        case .none:
            iconImageView.isHidden = true
        }
    }
    
}

private extension EditorNavigationBarTitleView {
    
    func setupView() {
        titleLabel.font = .bodyMedium
        titleLabel.textColor = .textColor
        titleLabel.numberOfLines = 1
        
        iconImageView.contentMode = .scaleAspectFit
        
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        setupLayout()        
    }
    
    func setupLayout() {
        addSubview(stackView) {
            $0.pinToSuperview()
        }
        
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        
        titleLabel.layoutUsing.anchors {
            $0.width.lessThanOrEqual(to: 160)
        }
        
        iconImageView.layoutUsing.anchors {
            $0.size(CGSize(width: 18, height: 18))
        }
    }
    
}
