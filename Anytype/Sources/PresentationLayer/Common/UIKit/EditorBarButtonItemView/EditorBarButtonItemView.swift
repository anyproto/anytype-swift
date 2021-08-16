//
//  EditorBarButtonItemView.swift
//  EditorBarButtonItemView
//
//  Created by Konstantin Mordan on 16.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

final class EditorBarButtonItemView: UIView {
    
    var withBackground: Bool = false {
        didSet {
            handleUpdateBackground()
        }
    }
    
    private let button = UIButton(type: .system)
    
    init(image: UIImage?, action: @escaping () -> Void) {
        super.init(frame: .zero)
        
        button.setImage(image, for: .normal)
        button.addAction(
            UIAction(
                handler: {_ in
                    action()
                }
            ),
            for: .touchUpInside
        )
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension EditorBarButtonItemView {
    
    func setupView() {
        decorate(with: .clipped())
        decorate(with: .rounded(radius: 7))
        decorate(with: .size(28, 28))
        
        addSubview(button) {
            $0.pinToSuperview()
        }
        
        handleUpdateBackground()
    }
    
    func handleUpdateBackground() {
        backgroundColor = withBackground ? .black.withAlphaComponent(0.35) : .clear
        button.tintColor = withBackground ? UIColor.grayscaleWhite : UIColor.secondaryTextColor
    }
    
}
