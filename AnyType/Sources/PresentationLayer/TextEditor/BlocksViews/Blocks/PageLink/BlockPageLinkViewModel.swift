
import UIKit
import Combine
import BlocksModels

/// ViewModel for type `.link()` with style `.page`
final class BlockPageLinkViewModel: BaseBlockViewModel {
    public let targetBlockId: String
    
    // Maybe we need also input and output subscribers.
    // MAYBE PAGE BLOCK IS ORDINARY TEXT BLOCK?
    // We can't edit name of the block.
    // Add subscription on event.
    private var subscriptions: Set<AnyCancellable> = []
    private typealias State = BlockPageLinkState
    private let router: EditorRouterProtocol?
    
    private var statePublisher: AnyPublisher<State, Never> = .empty()
    @Published private var state: State = .empty
    private var wholeDetailsViewModel: DetailsActiveModel = .init()
    weak var textView: (TextViewUpdatable & TextViewManagingFocus)?
    
    func getDetailsViewModel() -> DetailsActiveModel { self.wholeDetailsViewModel }
    
    init(
        _ block: BlockActiveRecordModelProtocol,
        targetBlockId: String,
        publisher: AnyPublisher<DetailsProviderProtocol, Never>?,
        router: EditorRouterProtocol?
    ) {
        self.targetBlockId = targetBlockId
        self.router = router
        
        super.init(block)

        setup(block: block)
        setupSubscriptions(publisher)
    }
    
    /// NOTES by Dima Lobanov:
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
    private func setupSubscriptions(_ publisher: AnyPublisher<DetailsProviderProtocol, Never>?) {
        guard let publisher = publisher else {
            return
        }
        
        wholeDetailsViewModel.configured(publisher: publisher)
        wholeDetailsViewModel.wholeDetailsPublisher.map(BlockPageLinkState.Converter.asOurModel).sink { [weak self] (value) in
            self?.state = value
        }.store(in: &subscriptions)
    }
    
    private func setup(block: BlockActiveRecordModelProtocol) {
        let information = block.blockModel.information
        switch information.content {
        case let .link(value):
            switch value.style {
            case .page:
                let pageId = value.targetBlockID // do we need it?
                self.wholeDetailsViewModel.configured(documentId: pageId)
                
                /// One possible way to do it is to get access to a container in flattener.
                /// Possible (?)
                /// OR
                /// We could set container to all page links when we parsing data.
                /// We could add additional field which stores publisher.
                /// In this case we move whole notification logic into model.
                /// Well, not so bad (?)
                
                self.$state.map(\.title).safelyUnwrapOptionals().receiveOnMain().sink { [weak self] (value) in
                    self?.textView?.apply(update: .text(value))
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
            switch self.getBlock().content {
            case let .link(linkContent):
                router?.showPage(with: linkContent.targetBlockID)
            default: return
            }
        }
    }
}

extension BlockPageLinkViewModel {
    func applyOnUIView(_ view: BlockPageLinkUIKitView) {
        _ = view.configured(stateStream: self.statePublisher).configured(state: self._state)
    }
}
