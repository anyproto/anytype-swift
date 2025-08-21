import CoreText
import UIKit

extension NSAttributedString {
    
    func sizeForLabel(width: CGFloat, maxLines: Int = 0) -> CGSize {
//        return ct_sizeForLabel(width: width, maxLines: maxLines)
        return bounding_sizeForLabel(width: width, maxLines: maxLines)
//        return tk_sizeForLabel(width: width, maxLines: maxLines)
    }
    
    /// Background-safe measurement for UILabel-like layout.
    /// Handles emoji/fallback fonts; avoids zero-height edge cases.
    /// - Parameters:
    ///   - width: target width constraint (points)
    ///   - maxLines: 0 = no limit; >0 = cap to this number of lines
    private func ct_sizeForLabel(width: CGFloat, maxLines: Int = 0) -> CGSize {
        let trailingPad: CGFloat = 5
        let maxH: CGFloat = 100_000
        let framesetter = CTFramesetterCreateWithAttributedString(self as CFAttributedString)
        let path = CGPath(rect: CGRect(x: 0, y: 0, width: width, height: maxH), transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: length), path, nil)

        let linesCF = CTFrameGetLines(frame)
        let totalLines = CFArrayGetCount(linesCF)
        if totalLines == 0 { return .zero }

        var origins = Array(repeating: CGPoint.zero, count: totalLines)
        CTFrameGetLineOrigins(frame, CFRange(location: 0, length: 0), &origins)

        let lines: [CTLine] = (0..<totalLines).compactMap {
            unsafeBitCast(CFArrayGetValueAtIndex(linesCF, $0), to: CTLine?.self)
        }

        let lineCount = maxLines > 0 ? min(maxLines, lines.count) : lines.count
        let firstIndex = 0
        let lastIndex  = lineCount - 1

        // Helper: prefer glyph path bounds; fallback to typographic if needed
        func lineBounds(_ line: CTLine) -> CGRect {
            var r = CTLineGetBoundsWithOptions(line, [.useGlyphPathBounds])
            if r.isNull || r.equalTo(.zero) {
                var asc: CGFloat = 0, desc: CGFloat = 0, lead: CGFloat = 0
                let w = CTLineGetTypographicBounds(line, &asc, &desc, &lead)
                r = CGRect(x: 0, y: -desc, width: CGFloat(w), height: asc + desc)
            }
            return r
        }

        // --- Height ---
        let firstB = lineBounds(lines[firstIndex])
        if lineCount == 1 {
            // Single-line: just return its height (with tiny pad)
            let usedH = ceil(firstB.height) + 0.5
            // --- Width (single-line): use actual used width to avoid right clipping ---
            let usedW = ceil((origins[firstIndex].x + firstB.maxX) - (origins[firstIndex].x + firstB.minX)) + trailingPad
            return CGSize(width: usedW, height: usedH)
        } else {
            // Multi-line height via baseline delta + last line extents
            let lastB = lineBounds(lines[lastIndex])
            let baselineDelta = origins[firstIndex].y - origins[lastIndex].y
            let lastAscent  = lastB.maxY
            let lastDescent = -lastB.minY
            var h = baselineDelta + lastAscent + lastDescent
            h = max(h, firstB.height)        // never below first line
            h = ceil(h) + 0.5                // small safety pad
            // --- Width (multi-line): keep constraint but add tiny trailing pad to avoid overhang cut ---
            let w = ceil(width) + trailingPad
            return CGSize(width: w, height: h)
        }
    }
    
    private func bounding_sizeForLabel(width: CGFloat, maxLines: Int) -> CGSize {
        let constraintBox = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintBox,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        var height = ceil(boundingBox.height)
        
        let font = attributes(at: 0, effectiveRange: nil)[.font] as? UIFont
        
        if maxLines > 0, let font {
            let lineHeight = font.lineHeight
            let maxHeight = lineHeight * CGFloat(maxLines)
            height = min(height, maxHeight)
        }
        
        return CGSize(width: ceil(boundingBox.width), height: height)
    }

    
    private func tk_sizeForLabel(width: CGFloat, maxLines: Int = 0, lineBreakMode: NSLineBreakMode = .byWordWrapping) -> CGSize {
            let storage = NSTextStorage(attributedString: self)
            let layout = NSLayoutManager()
            let container = NSTextContainer(size: CGSize(width: width, height: .greatestFiniteMagnitude))
            container.lineFragmentPadding = 0
            container.lineBreakMode = lineBreakMode
            container.maximumNumberOfLines = maxLines

            layout.addTextContainer(container)
            storage.addLayoutManager(layout)

            _ = layout.glyphRange(for: container)
            let used = layout.usedRect(for: container)
            return CGSize(width: ceil(min(used.width, width)), height: ceil(used.height) + 0.5)
        }
}
