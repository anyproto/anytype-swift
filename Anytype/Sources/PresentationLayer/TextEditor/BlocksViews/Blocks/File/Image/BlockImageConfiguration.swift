import UIKit
import BlocksModels

struct BlockImageConfiguration: UIContentConfiguration, Hashable {
    
    let fileData: BlockFile
    let maxWidth: CGFloat
    let alignment: LayoutAlignment
    
    init(fileData: BlockFile, alignmetn: LayoutAlignment, maxWidth: CGFloat) {
        self.fileData = fileData
        self.alignment = alignmetn
        self.maxWidth = maxWidth
    }
            
    func makeContentView() -> UIView & UIContentView {
        BlockImageContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> BlockImageConfiguration {
        self
    }
        
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.fileData == rhs.fileData &&
        lhs.alignment == rhs.alignment &&
        lhs.maxWidth.isEqual(to: rhs.maxWidth)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fileData)
        hasher.combine(alignment)
        hasher.combine(maxWidth)
    }
}
