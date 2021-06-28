
import BlocksModels
import UIKit

struct VideoBlockContentViewConfiguration {
    
    typealias Metadata = BlockFile.Metadata
    
    let state: BlockFileState
    let metadata: Metadata
    weak var blockViewModel: BaseBlockViewModel?
    
    init?(blockViewModel: BaseBlockViewModel) {
        if case let .file(file) = blockViewModel.block.content {
            self.state = file.state
            self.metadata = file.metadata
            self.blockViewModel = blockViewModel
        } else {
            return nil
        }
    }
}

extension VideoBlockContentViewConfiguration: UIContentConfiguration {
    
    func makeContentView() -> UIView & UIContentView {
        let view: VideoBlockContentView = .init(configuration: self)
        return view
    }
    
    func updated(for state: UIConfigurationState) -> VideoBlockContentViewConfiguration {
        self
    }
}

extension VideoBlockContentViewConfiguration: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.state == rhs.state &&
        lhs.metadata == rhs.metadata
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.state)
        hasher.combine(self.metadata)
    }
}
