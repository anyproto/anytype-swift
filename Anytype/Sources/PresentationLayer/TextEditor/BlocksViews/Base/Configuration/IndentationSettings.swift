import UIKit
import BlocksModels

struct IndentationSettings: Equatable {
    let parentColors: [UIColor?]
}

extension IndentationSettings {
    init(with metadata: BlockInformationMetadata) {
        parentColors = metadata.parentBackgroundColors.map { middlewareColor -> UIColor? in
            middlewareColor.map(UIColor.Background.uiColor(from:)) ?? nil
        }
    }
}
