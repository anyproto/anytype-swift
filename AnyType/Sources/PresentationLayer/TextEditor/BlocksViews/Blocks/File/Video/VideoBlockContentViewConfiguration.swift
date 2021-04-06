
import BlocksModels
import UIKit

struct VideoBlockContentViewConfiguration {
    
    typealias State = Block.Content.ContentType.File.State
    typealias Metadata = Block.Content.ContentType.File.Metadata
    
    let state: State
    let metadata: Metadata
    weak var blockViewModel: BlocksViews.New.Base.ViewModel?
    
    init?(blockViewModel: BlocksViews.New.Base.ViewModel) {
        if case let .file(file) = blockViewModel.getBlock().blockModel.information.content {
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
        self.blockViewModel?.addContextMenuIfNeeded(view)
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
