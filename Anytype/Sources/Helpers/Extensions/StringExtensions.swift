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
    
    func image(fontPointSize: CGFloat) -> UIImage? {
        let font = UIFont.systemFont(ofSize: fontPointSize)
        let actualSize = NSString(string: self).boundingRect(with:  CGSize(width: CGFloat.greatestFiniteMagnitude,
                                                                           height: CGFloat.greatestFiniteMagnitude),
                                                             options: [.usesFontLeading, .usesLineFragmentOrigin],
                                                             attributes: [.font: font],
                                                             context: nil).size
        let rect = CGRect(origin: .zero, size: actualSize)
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { _ in
            (self as AnyObject).draw(in: rect, withAttributes: [.font: font])
        }
    }
    
    func isValidURL() -> Bool {
        guard !isEmpty,
              let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return false }
        let range = detector.rangeOfFirstMatch(
            in: self,
            range: NSRange(location: 0, length: count)
        )
        return range.location == 0 && range.length == count
    }
}
