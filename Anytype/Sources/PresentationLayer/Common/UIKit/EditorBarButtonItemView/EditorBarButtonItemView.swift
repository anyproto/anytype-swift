//
//  EditorBarButtonItemView.swift
//  EditorBarButtonItemView
//
//  Created by Konstantin Mordan on 16.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

final class EditorBarButtonItemView: UIView {
    
    var hasBackground: Bool = false {
        didSet {
            handleUpdateBackground()
        }
    }
    
    private let button = UIButton(type: .custom)
    
    init(image: UIImage?, action: @escaping () -> Void) {
        super.init(frame: .zero)
        
        setupView(image: image, action: action)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension EditorBarButtonItemView {
    
    func setupView(image: UIImage?, action: @escaping () -> Void) {
        clipsToBounds = true
        layer.cornerRadius = 7
        layoutUsing.anchors {
            $0.size(CGSize(width: 28, height: 28))
        }
        
        button.setImage(image, for: .normal)
        button.adjustsImageWhenHighlighted = false
        
        button.addAction(
            UIAction(
                handler: {_ in
                    action()
                }
            ),
            for: .touchUpInside
        )
                
        addSubview(button) {
            $0.pinToSuperview()
        }
        
        handleUpdateBackground()
        
        enableAnimation(
            .scale(toScale: Constants.pressedScale, duration: Constants.animationDuration),
            .undoScale(scale: Constants.pressedScale, duration: Constants.animationDuration)
        )
    }
    
    func handleUpdateBackground() {
        backgroundColor = hasBackground ? .black.withAlphaComponent(0.35) : .clear
        button.tintColor = hasBackground ? UIColor.grayscaleWhite : UIColor.secondaryTextColor
    }
    
}

private extension EditorBarButtonItemView {
    
    func enableAnimation(_ inAnimator: ViewAnimator<UIView>, _ outAnimator: ViewAnimator<UIView>) {
        let recognizer = TouchGestureRecognizer { [weak self] recognizer in
            guard
                let self = self
            else {
                return
            }
            switch recognizer.state {
            case .began:
                inAnimator.animate(self.button)
            case .ended, .cancelled, .failed:
                outAnimator.animate(self.button)
            default:
                return
            }
        }
        recognizer.cancelsTouchesInView = false
        button.addGestureRecognizer(recognizer)
    }
    
    enum Constants {
        static let animationDuration: TimeInterval = 0.1
        static let pressedScale: CGFloat = 0.8
    }
    
}
