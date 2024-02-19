import UIKit
import Services

struct BlockImageConfiguration: BlockConfiguration {
    typealias View = BlockImageContentView

    let blockId: String
    let maxWidth: CGFloat
    let alignment: LayoutAlignment
    @EquatableNoop private(set) var fileData: BlockFile
    @EquatableNoop private(set) var imageViewTapHandler: (UIImageView) -> Void

    init(
        blockId: String,
        maxWidth: CGFloat,
        alignment: LayoutAlignment,
        fileData: BlockFile,
        imageViewTapHandler: @escaping (UIImageView) -> Void
    ) {
        self.blockId = blockId
        self.maxWidth = maxWidth
        self.alignment = alignment
        self.fileData = fileData
        self.imageViewTapHandler = imageViewTapHandler
    }
}
