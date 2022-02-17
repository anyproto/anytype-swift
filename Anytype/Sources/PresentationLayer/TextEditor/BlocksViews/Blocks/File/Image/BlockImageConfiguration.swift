import UIKit
import BlocksModels

struct BlockImageConfiguration: BlockConfiguration {
    typealias View = BlockImageContentView
    
    let fileData: BlockFile
    let maxWidth: CGFloat
    let alignment: LayoutAlignment
    @EquatableNoop private(set) var imageViewTapHandler: (UIImageView) -> Void

    init(
        fileData: BlockFile,
        alignmetn: LayoutAlignment,
        maxWidth: CGFloat,
        imageViewTapHandler: @escaping (UIImageView) -> Void
    ) {
        self.fileData = fileData
        self.alignment = alignmetn
        self.maxWidth = maxWidth
        self.imageViewTapHandler = imageViewTapHandler
    }
}
