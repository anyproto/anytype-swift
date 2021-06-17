//
//  StringExtensions.swift
//  Anytype
//
//  Created by Konstantin Mordan on 14.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit

extension String {
    
    var isSingleEmoji: Bool {
        count == 1 && containsEmoji
    }

    var containsEmoji: Bool {
        contains { $0.isEmoji }
    }

    var containsOnlyEmoji: Bool {
        !isEmpty && !contains { !$0.isEmoji }
    }
    
    func image(contextSize: CGSize,
               imageSize: CGSize,
               imageOffset: CGPoint = .zero,
               font: UIFont) -> UIImage? {
        let rect = CGRect(origin: .zero, size: contextSize)
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { _ in
            let imageRect = CGRect(origin: imageOffset, size: imageSize)
            (self as AnyObject).draw(in: imageRect, withAttributes: [.font: font])
        }
    }
}
