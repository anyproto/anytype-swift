import UIKit
import BlocksModels

struct BlockIndentationSettings: Equatable {
    let color: UIColor?
    let indentationStyle: BlockIndentationStyle
}

struct IndentationSettings: Equatable {
    let parentBlocksInfo: [BlockIndentationSettings]
    let style: BlockIndentationStyle
    let backgroundColor: UIColor?
    let bottomBackgroundColor: UIColor?
}

extension IndentationSettings {
    init(with metadata: BlockInformationMetadata) {
        var parentBlockInfo = [BlockIndentationSettings]()

        for (style, color) in zip(metadata.parentIndentationStyle, metadata.parentBackgroundColors) {
            let uiColor = color.map(UIColor.VeryLight.uiColor(from:)) ?? nil

            parentBlockInfo.append(.init(color: uiColor, indentationStyle: style))
        }

        let backgroundColor: UIColor?
        if metadata.indentationStyle == .callout { // Callout background engineering
            if let middlewareColor = metadata.backgroundColor, middlewareColor != .default {
                backgroundColor = UIColor.VeryLight.uiColor(from: middlewareColor)
            } else {
                backgroundColor = UIColor.VeryLight.grey
            }
        } else if let middlewareColor = metadata.backgroundColor, middlewareColor != .default {
            backgroundColor = UIColor.VeryLight.uiColor(from: middlewareColor)
        } else {
            backgroundColor = nil
        }

        self.parentBlocksInfo = parentBlockInfo
        self.style = metadata.indentationStyle
        self.backgroundColor = backgroundColor
        self.bottomBackgroundColor = metadata.calloutBackgroundColor.map { UIColor.VeryLight.uiColor(from: $0) }
    }
}
