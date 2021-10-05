//
//  EditorBarButtonItemView.swift
//  EditorBarButtonItemView
//
//  Created by Konstantin Mordan on 16.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

final class EditorBarButtonItemView: UIView, CustomizableHitTestAreaView {
    var minHitTestArea: CGSize = Constants.minimumHitArea

    var backgroundAlpha: CGFloat = 0.0 {
        didSet {
            handleAlphaUpdate(backgroundAlpha)
        }
    }
    
    private let backgroundView = UIView()
    
    private let button = UIButton(type: .custom)
    
    init(image: UIImage, action: @escaping () -> Void) {
        super.init(frame: .zero)
        
        setupView(image: image, action: action)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return containsCustomHitTestArea(point) ? self.button : nil
    }
}

private extension EditorBarButtonItemView {
    
    func setupView(image: UIImage, action: @escaping () -> Void) {
        setupBackgroundView()
        setupButton(image: image, action: action)
        setupLayout()
        
        handleAlphaUpdate(backgroundAlpha)
        
        enableAnimation(
            .scale(toScale: Constants.pressedScale, duration: Constants.animationDuration),
            .undoScale(scale: Constants.pressedScale, duration: Constants.animationDuration)
        )
    }
    
    func setupBackgroundView() {
        backgroundView.backgroundColor = .black.withAlphaComponent(0.35)
        backgroundView.layer.cornerRadius = 7
    }
    
    func setupButton(image: UIImage, action: @escaping () -> Void) {
        button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.adjustsImageWhenHighlighted = false
        
        button.addAction(
            UIAction(
                handler: {_ in
                    action()
                }
            ),
            for: .touchUpInside
        )
    }
    
    func setupLayout() {
        layoutUsing.anchors {
            $0.size(CGSize(width: 28, height: 28))
        }
        
        addSubview(backgroundView) {
            $0.pinToSuperview()
        }
        
        addSubview(button) {
            $0.pinToSuperview()
        }
    }
    
    func handleAlphaUpdate(_ alpha: CGFloat) {
        backgroundView.alpha = alpha
        button.tintColor = alpha.isLess(than: 0.5) ? UIColor.textSecondary : UIColor.backgroundPrimary
    }
    
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
    
}

private extension EditorBarButtonItemView {
    
    enum Constants {
        static let animationDuration: TimeInterval = 0.1
        static let pressedScale: CGFloat = 0.8
        
        static let minimumHitArea = CGSize(width: 44, height: 44)
    }
    
}
