//
//  TouchGestureRecognizer.swift
//  TouchGestureRecognizer
//
//  Created by Konstantin Mordan on 16.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

final class TouchGestureRecognizer: UIGestureRecognizer {
    
    private var action: ((UIGestureRecognizer) -> Void)?
    
    /// Initializes the class with the touch action.
    ///
    /// - Parameter action: The action, called when a touch occurs.
    public init(action: ((UIGestureRecognizer) -> Void)?) {
        self.action = action
        
        super.init(target: nil, action: nil)
        
        addTarget(self, action: #selector(onTouch))
        
        cancelsTouchesInView = false
    }
    
    @objc
    private func onTouch() {
        action?(self)
    }
    
    override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        guard
            let touch = touches.first,
            let view = touch.view,
            view == self.view || !(view is UIControl)
        else {
            return
        }
        
        state = .began
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        guard
            let view = view,
            let point = touches.first?.location(in: view)
        else {
            return
        }
        
        if view.bounds.contains(point) {
            state = .possible
        } else {
            state = .ended
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        
        state = .ended
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        
        state = .cancelled
    }
    
}
