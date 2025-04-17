//
//  ViewAnimator+Scale.swift
//  ViewAnimator+Scale
//
//  Created by Konstantin Mordan on 16.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

@MainActor
public extension ViewAnimator {
    
    static func scale(
        toScale: CGFloat,
        fromScale: CGFloat? = nil,
        duration: TimeInterval = 0,
        fillMode: CAMediaTimingFillMode = .removed
    ) -> ViewAnimator {
        ViewAnimator {
            let initialTransformClosure = { (layer: CALayer) -> CATransform3D in
                guard let scale = fromScale else {
                    return layer.presentation()?.transform ?? layer.transform
                }
                
                return CATransform3DMakeScale(scale, scale, 1)
            }
            
            let initialTransform = initialTransformClosure($0.layer)
            let targetTransform = CATransform3DMakeScale(toScale, toScale, 1)
            let duration = duration * getScaleAnimationProgress(
                scale: toScale,
                in: $0.layer
            )
            
            $0.layer.transform = targetTransform
            
            animate(
                $0.layer,
                initialTransform: initialTransform,
                targetTransform: targetTransform,
                duration: duration,
                fillMode: fillMode
            )
        }
    }
    
    static func undoScale(
        scale: CGFloat,
        duration: TimeInterval = 0,
        fillMode: CAMediaTimingFillMode = .removed
    ) -> ViewAnimator {
        ViewAnimator {
            let initialTransform = $0.layer.presentation()?.transform ?? $0.layer.transform
            let targetTransform = CATransform3DMakeScale(1, 1, 1)
            let progress = getScaleAnimationProgress(
                scale: scale,
                in: $0.layer
            )
            
            let duration = duration * (1 - progress)
            $0.layer.transform = targetTransform
            
            animate(
                $0.layer,
                initialTransform: initialTransform,
                targetTransform: targetTransform,
                duration: duration,
                fillMode: fillMode
            )
            
        }
    }
    
}

private extension ViewAnimator {
    
    private static func getScaleAnimationProgress(scale: CGFloat, in layer: CALayer) -> Double {
        guard let presentationLayer = layer.presentation() else {
            return 0
        }
        
        let currentScale = presentationLayer.transform.m11
        return Double((currentScale - scale) / (1 - scale))
    }
    
    private static func animate(
        _ layer: CALayer,
        initialTransform: CATransform3D,
        targetTransform: CATransform3D,
        duration: TimeInterval,
        fillMode: CAMediaTimingFillMode
    ) {
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        animation.duration = duration
        animation.fromValue = initialTransform
        animation.toValue = targetTransform
        animation.fillMode = fillMode
        
        let key = "scale_animation"
        layer.removeAnimation(forKey: key)
        layer.add(animation, forKey: key)
    }
    
}
