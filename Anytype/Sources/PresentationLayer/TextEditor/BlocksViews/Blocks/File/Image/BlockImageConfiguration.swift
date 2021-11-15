import UIKit
import BlocksModels

struct BlockImageConfiguration: BlockConfigurationProtocol, Hashable {
    
    let fileData: BlockFile
    let maxWidth: CGFloat
    let alignment: LayoutAlignment
    let imageViewTapHandler: (UIImageView) -> Void
    var currentConfigurationState: UICellConfigurationState?
    
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
            
    func makeContentView() -> UIView & UIContentView {
        BlockImageContentView(configuration: self)
    }
        
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.fileData == rhs.fileData &&
        lhs.alignment == rhs.alignment &&
        lhs.maxWidth.isEqual(to: rhs.maxWidth) &&
        lhs.currentConfigurationState == rhs.currentConfigurationState
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fileData)
        hasher.combine(alignment)
        hasher.combine(maxWidth)
        hasher.combine(currentConfigurationState)
    }
}
