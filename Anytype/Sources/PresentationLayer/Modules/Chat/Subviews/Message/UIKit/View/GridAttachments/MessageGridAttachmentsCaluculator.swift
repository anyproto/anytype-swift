import Foundation
import UIKit

struct MessageGridAttachmentsCaluculator {
    
    private enum Constants {
        static let spacing: CGFloat = 4
    }
    
    static func calculateSize(targetSize: CGSize, attachments: [MessageAttachmentDetails]) -> MessageGridAttachmentsContainerLayout {
        
        var frames: [CGRect] = []
        
        let width = targetSize.width
        
        var height: CGFloat = 0
        let rowsCountByLine = makeGridRows(countItems: attachments.count)
        
        for (index, rowItems) in rowsCountByLine.enumerated() {
            let rowHeight = (width - (rowItems - 1) * Constants.spacing) / CGFloat(rowItems)
            
            var frameX: CGFloat = 0
            
            for _ in 0..<rowItems {
                let frame = CGRect(
                    x: frameX,
                    y: height,
                    width: rowHeight,
                    height: rowHeight
                )
                frames.append(frame)
                frameX += rowHeight + Constants.spacing
            }
            
            if index == (rowsCountByLine.count - 1) {
                height += rowHeight
            } else {
                height += (rowHeight + Constants.spacing)
            }
        }
        
        let calculatedSize = CGSize(width: width, height: height)
        
        return MessageGridAttachmentsContainerLayout(
            size: calculatedSize,
            objectFrames: frames
        )
    }
    
    private static func makeGridRows(countItems: Int) -> [Int] {
        
        var items = countItems
        var result = [Int]()
        
        while items > 0 {
            let newItems2 = items - 2
            let newItems3 = items - 3
            
            if newItems3 >= 2 || newItems3 == 0 {
                result.append(3)
                items = newItems3
            } else if newItems2 > 1 || newItems2 == 0 {
                result.append(2)
                items = newItems2
            } else { // items == 1
                result.append(1)
                items = 0
            }
            
        }
        
        return result.reversed()
    }
}
