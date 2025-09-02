import Foundation
import UIKit

struct MessageGridAttachmentsContainerLayout: Equatable {
    let size: CGSize
    let objectFrames: [CGRect]
}

struct MessageGridAttachmentsCaluculator {
    
    private enum Constants {
        static let spacing: CGFloat = 4
    }
    
    static func calculateSize(targetSize: CGSize, attachments: [MessageAttachmentDetails]) -> MessageGridAttachmentsContainerLayout {
        
        var frames: [CGRect] = []
        
        let width = targetSize.width
        
        var height: CGFloat = 0
        let rowsCountByLine = MessageAttachmentsGridLayoutBuilder.makeGridRows(countItems: attachments.count)
        
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
}
