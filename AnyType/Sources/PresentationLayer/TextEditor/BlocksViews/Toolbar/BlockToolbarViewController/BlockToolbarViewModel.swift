import SwiftUI
import Combine

final class BlockToolbarViewModel {
    // MARK: Variables
    var action: AnyPublisher<BlockToolbarAction, Never> = .empty()
    var dismissControllerPublisher: AnyPublisher<Void, Never> = .empty()
    private var style: Style
    
    // MARK: Subscriptions
    private var subscriptions: Set<AnyCancellable> = []
            
    // MARK: Models
    @ObservedObject private var addBlockViewModel: BlockToolbarAddBlock.ViewModel
    @ObservedObject private var turnIntoBlockViewModel: BlockToolbarTurnIntoBlock.ViewModel
    @ObservedObject private var bookmarkViewModel: BlockToolbarBookmark.ViewModel
    
    // MARK: Setup
    private func publisher(style: Style) -> AnyPublisher<BlockToolbarAction, Never> {
        switch style.style {
        case .addBlock: return self.addBlockViewModel.chosenBlockTypePublisher.safelyUnwrapOptionals().map { value in
            BlockToolbarAction.addBlock(value)
        }.eraseToAnyPublisher()
        case .turnIntoBlock: return self.turnIntoBlockViewModel.chosenBlockTypePublisher.safelyUnwrapOptionals().map { value in
            BlockToolbarAction.turnIntoBlock(value)
        }.eraseToAnyPublisher()
        case .bookmark: return self.bookmarkViewModel.userAction.map({ value in
            BlockToolbarAction.bookmark(.fetch(value))
        }).eraseToAnyPublisher()
        }
    }
    private func setup(style: Style) {
        self.action = self.publisher(style: style)
        self.dismissControllerPublisher = self.action.successToVoid().eraseToAnyPublisher()
    }
    
    // MARK: Initialization
    init(_ style: Style) {
        self.style = style
        self.addBlockViewModel = BlockToolbarAddBlock.ViewModelBuilder.create()
        self.turnIntoBlockViewModel = BlockToolbarTurnIntoBlock.ViewModelBuilder.create()
        self.bookmarkViewModel = BlockToolbarBookmark.ViewModelBuilder.create()
        
        if let filtering = self.style.filtering {
            _ = self.addBlockViewModel.configured(filtering: filtering)
            _ = self.turnIntoBlockViewModel.configured(filtering: filtering)
        }
        self.setup(style: style)
    }
            
    // MARK: Get Chosen View
    func chosenView() -> StyleAndViewAndPayload {
        switch self.style.style {
        case .addBlock: return .init(style: self.style, view: BlockToolbarAddBlock.InputViewBuilder.createView(self._addBlockViewModel), payload: .init(title: self.addBlockViewModel.title))
        case .turnIntoBlock: return .init(style: self.style, view: BlockToolbarTurnIntoBlock.InputViewBuilder.createView(self._turnIntoBlockViewModel), payload: .init(title: self.turnIntoBlockViewModel.title))
        case .bookmark: return .init(style: self.style, view: BlockToolbarBookmark.InputViewBuilder.createView(self._bookmarkViewModel), payload: .init(title: self.bookmarkViewModel.title))
        }
    }
}

// MARK: Subscriptions
// TODO: Move this method to protocol.
// Theoretically each class can get power of this method.
extension BlockToolbarViewModel {
    func subscribe<S, T>(subject: S, keyPath: KeyPath<BlockToolbarViewModel, T>) where T: Publisher, S: Subject, T.Output == S.Output, T.Failure == S.Failure {
        self[keyPath: keyPath].subscribe(subject).store(in: &self.subscriptions)
    }
}

// MARK: StyleAndViewAndPayload
extension BlockToolbarViewModel {
    struct StyleAndViewAndPayload {
        struct Payload {
            let title: String
        }
        let style: Style
        let view: UIView?
        let payload: Payload?
    }
}

// MARK: Style
extension BlockToolbarViewModel {
    /// Necessary for different toolbars.
    /// We should add turnInto later.
    /// And may be we could add action toolbar here...
    ///
    struct Style {
        enum OurStyle {
            case addBlock, turnIntoBlock, bookmark
        }
        
        fileprivate var style: OurStyle = .addBlock
        fileprivate var filtering: BlockToolbarAddBlock.ViewModel.BlocksTypesCasesFiltering?
        
        init(style: BlockToolbarViewModel.Style.OurStyle = .addBlock, filtering: BlockToolbarAddBlock.ViewModel.BlocksTypesCasesFiltering? = nil) {
            self.style = style
            self.filtering = filtering
        }
    }
}
