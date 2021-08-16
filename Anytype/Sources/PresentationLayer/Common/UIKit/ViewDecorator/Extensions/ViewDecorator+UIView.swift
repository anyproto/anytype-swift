//
//  ViewDecorator+UIView.swift
//  ViewDecorator+UIView
//
//  Created by Konstantin Mordan on 16.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

extension ViewDecorator where View: UIView {
    
    /// Sets the corner radius of the view.
    ///
    /// - Parameter radius: The corner radius.
    /// - Returns: An instance if the ViewDecorator.
    static func rounded(radius: CGFloat) -> ViewDecorator<View> {
        ViewDecorator<View> {
            if $0 is UIVisualEffectView {
                $0.clipsToBounds = true
            }
            
            $0.layer.cornerRadius = radius
        }
    }
    
    /// Sets the mask of the view.
    ///
    /// - Parameter path: Path with which view will be masked.
    /// - Parameter bounds: Bounds in which view will be masked if mask is reversed.
    /// If no such parameter then view's current bounds will be used.
    /// - Parameter reversed: Determines if mask must be reversed.
    /// - Returns: An instance if the ViewDecorator.
    static func masked(with path: UIBezierPath, within bounds: CGRect? = nil, reversed: Bool = false) -> ViewDecorator<View> {
        ViewDecorator<View> {
            let path = path
            let maskLayer = CAShapeLayer()
            
            if reversed {
                maskLayer.fillRule = .evenOdd
                let bounds = bounds ?? $0.bounds
                path.append(UIBezierPath(rect: bounds))
            }
            
            maskLayer.path = path.cgPath
            maskLayer.backgroundColor = UIColor.black.cgColor
            
            $0.layer.mask = maskLayer
            $0.layer.masksToBounds = true
        }
    }
    
    /// Adds the height and the width constraints to the view.
    /// - Parameter size: The size constants.
    static func size(_ size: CGSize) -> ViewDecorator<View> {
        ViewDecorator<View> {
            $0.layoutUsing.anchors {
                $0.size(size)
            }
        }
    }
    
    /// Adds the height and the width constraints to the view.
    /// - Parameter width: The width constant.
    /// - Parameter height: The height constant.
    static func size(_ width: CGFloat, _ height: CGFloat) -> ViewDecorator<View> {
        size(CGSize(width: width, height: height))
    }
    
    /// Adds the height constraints to the view.
    /// - Parameter height: The height constants.
    static func height(_ height: CGFloat) -> ViewDecorator<View> {
        ViewDecorator<View> {
            $0.layoutUsing.anchors {
                $0.height.equal(to: height)
            }
        }
    }
    
    /// Adds the width constraint to the view.
    /// - Parameter width: The width constant.
    static func width(_ width: CGFloat) -> ViewDecorator<View> {
        ViewDecorator<View> {
            $0.layoutUsing.anchors {
                $0.width.equal(to: width)
            }
        }
    }
    
    /// Adds the minimum height constraints to the view.
    /// - Parameter height: The minimum height constants.
    static func minHeight(_ height: CGFloat) -> ViewDecorator<View> {
        ViewDecorator<View> {
            $0.layoutUsing.anchors {
                $0.height.greaterThanOrEqual(to: height)
            }
        }
    }

    /// Adds the minimum width constraints to the view.
    /// - Parameter width: The minimum height constants.
    static func minWidth(_ width: CGFloat) -> ViewDecorator<View> {
        ViewDecorator<View> {
            $0.layoutUsing.anchors {
                $0.width.greaterThanOrEqual(to: width)
            }
        }
    }
    
    /// Adds the layout to the view.
    /// - Parameter layout: The LayoutProxy.
    static func layout(_ layout: @escaping (LayoutProxy) -> Void) -> ViewDecorator<View> {
        ViewDecorator<View> {
            $0.layoutUsing.anchors {
                layout($0)
            }
        }
    }
    
    /// Change the alpha to the view.
    /// - Parameter value: The alpha.
    static func alpha(_ value: CGFloat) -> ViewDecorator<View> {
        ViewDecorator<View> {
            $0.alpha = value
        }
    }

    /// Sets the background color of the view.
    ///
    /// - Parameter color: The background color.
    /// - Returns: An instance if the ViewDecorator.
    static func filled(_ color: UIColor) -> ViewDecorator<View> {
        ViewDecorator<View> {
            $0.backgroundColor = color
        }
    }
    
    static func clipped(_ isClipped: Bool = true) -> ViewDecorator<View> {
        ViewDecorator<View> {
            $0.clipsToBounds = isClipped
        }
    }
    
    static func userInteractionEnabled(_ isUserInteractionEnabled: Bool) -> ViewDecorator<View> {
        ViewDecorator<View> {
            $0.isUserInteractionEnabled = isUserInteractionEnabled
        }
    }
    
    static func contentMode(_ mode: UIView.ContentMode) -> ViewDecorator<View> {
        ViewDecorator<View> {
            $0.contentMode = mode
        }
    }
    
    static func hidden(_ isHidden: Bool = true) -> ViewDecorator<View> {
        ViewDecorator<View> {
            $0.isHidden = isHidden
        }
    }

    static func accessibility(identifier: String) -> ViewDecorator<View> {
        ViewDecorator<View> {
            $0.accessibilityIdentifier = identifier
        }
    }

    static func layoutMargins(_ layoutMargins: UIEdgeInsets) -> ViewDecorator<View> {
        ViewDecorator<View> {
            $0.layoutMargins = layoutMargins
        }
    }
    
    static func border(color: UIColor, width: CGFloat) -> ViewDecorator<View> {
        ViewDecorator<View> {
            $0.layer.borderColor = color.cgColor
            $0.layer.borderWidth = width
        }
    }
    
}
