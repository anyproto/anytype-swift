
import UIKit
import Combine
import BlocksModels

/// ViewModel for type `.link()` with style `.page`
/// Should we move it to PageBlocksViews? (?)
///
final class BlockPageLinkViewModel: BaseBlockViewModel {
    // Maybe we need also input and output subscribers.
    // MAYBE PAGE BLOCK IS ORDINARY TEXT BLOCK?
    // We can't edit name of the block.
    // Add subscription on event.
    private var subscriptions: Set<AnyCancellable> = []
    private typealias State = BlockPageLinkState
    
    private var statePublisher: AnyPublisher<State, Never> = .empty()
    @Published private var state: State = .empty
    private lazy var textViewModel = TextView.UIKitTextView.ViewModel(blockViewModel: self)
    private var wholeDetailsViewModel: DetailsActiveModel = .init()
    
    func getDetailsViewModel() -> DetailsActiveModel { self.wholeDetailsViewModel }
    
    override init(_ block: BlockModel) {
        super.init(block)
        self.setup(block: block)
    }
    
    private func setup(block: BlockModel) {
        let information = block.blockModel.information
        switch information.content {
        case let .link(value):
            switch value.style {
            case .page:
                let pageId = value.targetBlockID // do we need it?
                _ = self.wholeDetailsViewModel.configured(documentId: pageId)
                
                /// One possible way to do it is to get access to a container in flattener.
                /// Possible (?)
                /// OR
                /// We could set container to all page links when we parsing data.
                /// We could add additional field which stores publisher.
                /// In this case we move whole notification logic into model.
                /// Well, not so bad (?)
                
                self.$state.map(\.title).safelyUnwrapOptionals().receive(on: RunLoop.main).sink { [weak self] (value) in
                    self?.textViewModel.update = .text(value)
                }.store(in: &self.subscriptions)
                
                self.statePublisher = self.$state.eraseToAnyPublisher()
            default: return
            }
        default: return
        }
    }
    
    override func makeContentConfiguration() -> UIContentConfiguration {
        if var configuration = BlockPageLinkContentConfiguration(self.getBlock().blockModel.information) {
            configuration.contextMenuHolder = self
            return configuration
        }
        return super.makeContentConfiguration()
    }
    
    override func handle(event: BlocksViews.UserEvent) {
        switch event {
        case .didSelectRowInTableView:
            switch self.getBlock().blockModel.information.content {
            case let .link(value):
                self.send(userAction: .specific(.tool(.pageLink(.shouldShowPage(value.targetBlockID)))))
            default: return
            }
        }
    }

    // MARK: Contextual Menu
    override func makeContextualMenu() -> BlocksViews.ContextualMenu {
        .init(title: "", children: [
            .create(action: .general(.addBlockBelow)),
            .create(action: .specific(.turnInto)),
            .create(action: .general(.delete)),
            .create(action: .general(.duplicate)),
            .create(action: .specific(.rename)),
            .create(action: .general(.moveTo)),
            .create(action: .specific(.backgroundColor)),
        ])
    }
}

extension BlockPageLinkViewModel {
    func applyOnUIView(_ view: BlockPageLinkUIKitView) {
        _ = view.textView.configured(.init(liveUpdateAvailable: true))
        _ = view.textView.configured(self.textViewModel)
        _ = view.configured(stateStream: self.statePublisher).configured(state: self._state)
    }
}

// MARK: - Configurations
extension BlockPageLinkViewModel {
    /// NOTES:
    /// Look at this method carefully.
    /// We have to pass publisher for `self.wholeDetailsViewModel`.
    /// Why so?
    ///
    /// Short story: Link should listen their own Details publisher.
    ///
    /// Long story:
    /// `BlockShow` will send details for open page with title and with icon.
    /// These details are shown on page itself.
    ///
    /// But it also contains `details` for all `links` that this page `contains`.
    ///
    /// So, if you change `details` or `title` of a `page` that this `link` is point to, so, all opened pages with link to changed page will receive updates.
    ///
    func configured(_ publisher: AnyPublisher<DetailsActiveModel.PageDetails, Never>) -> Self {
        self.wholeDetailsViewModel.configured(publisher: publisher)
        self.wholeDetailsViewModel.wholeDetailsPublisher.map(BlockPageLinkState.Converter.asOurModel).sink { [weak self] (value) in
            self?.state = value
        }.store(in: &self.subscriptions)
        return self
    }
}
