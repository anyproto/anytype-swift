import Foundation
import UIKit

struct MessageTextCalculator {
    
    static func calculateSize(targetSize: CGSize, data: MessageTextViewData) -> MessageTextLayout {
        
        let syncIconSize = CGSize(width: 12, height: 12)
        
        let textForCalculator = NSMutableAttributedString(attributedString: data.message)
        textForCalculator.append(NSAttributedString(string: "  "))
        if data.synced.isNotNil {
            textForCalculator.append(NSAttributedString(string: "   "))
        }
        textForCalculator.append(data.infoText)
        
        let size = textForCalculator.sizeForLabel(width: targetSize.width, maxLines: 0)
        let textSize = data.message.sizeForLabel(width: targetSize.width, maxLines: 0)
        let infoSize = data.infoText.sizeForLabel(width: targetSize.width, maxLines: MessageTextViewData.infoLineLimit)
        
        let infoFrame = CGRect(
            origin: CGPoint(x: size.width - infoSize.width, y: size.height - infoSize.height),
            size: infoSize
        )
        
        var syncIconFrame: CGRect? = .zero
        if data.synced.isNotNil {
            syncIconFrame = CGRect(
                origin: CGPoint(
                    x: infoFrame.minX - syncIconSize.width - 2,
                    y: infoFrame.minY + (infoFrame.height - syncIconSize.height) * 0.5
                ),
                size: syncIconSize
            )
        }
        
        return MessageTextLayout(
            size: size,
            textFrame: CGRect(origin: .zero, size: textSize),
            infoFrame: infoFrame,
            syncIconFrame: syncIconFrame
        )
    }
    
}
