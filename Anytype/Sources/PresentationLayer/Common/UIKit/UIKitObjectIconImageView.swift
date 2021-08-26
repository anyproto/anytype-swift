//
//  UIKitObjectIconImageView.swift
//  UIKitObjectIconImageView
//
//  Created by Konstantin Mordan on 26.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

// TODO: rename

final class UIKitObjectIconImageView: UIView {
    
    private let imageView = UIImageView()
    
    init() {
        super.init(frame: .zero)
        
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension UIKitObjectIconImageView {
    
    func setupLayout() {
        addSubview(imageView) {
            $0.pinToSuperview()
        }
    }
    
}
