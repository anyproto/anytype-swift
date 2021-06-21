
import UIKit
import Combine
import BlocksModels


/// ViewModel for type `.link()` with style `.page`
final class BlockPageLinkViewModel: BaseBlockViewModel {
    public let targetBlockId: String
    private var subscriptions: Set<AnyCancellable> = []
    private let router: EditorRouterProtocol?

    @Published private(set) var state: BlockPageLinkState = .empty
    private var wholeDetailsViewModel: DetailsActiveModel = .init()


    init(
        _ block: BlockActiveRecordModelProtocol,
        targetBlockId: String,
        publisher: AnyPublisher<DetailsData, Never>?,
        router: EditorRouterProtocol?,
        delegate: BaseBlockDelegate?
    ) {
        self.targetBlockId = targetBlockId
        self.router = router
        
        super.init(block, delegate: delegate)

        setup(block: block)
        setupSubscriptions(publisher)
    }

    func getDetailsViewModel() -> DetailsActiveModel { self.wholeDetailsViewModel }
    
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
    private func setupSubscriptions(_ publisher: AnyPublisher<DetailsData, Never>?) {
        guard let publisher = publisher else {
            return
        }
        
        wholeDetailsViewModel.configured(publisher: publisher)
        wholeDetailsViewModel.wholeDetailsPublisher
            .map(BlockPageLinkState.Converter.asOurModel)
            .receiveOnMain()
            .sink { [weak self] (value) in
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
                wholeDetailsViewModel.configured(documentId: pageId)
            default: return
            }
        default: return
        }
    }
    
    override func makeContentConfiguration() -> UIContentConfiguration {
        if var configuration = BlockPageLinkContentConfiguration(block.blockModel.information) {
            configuration.viewModel = self
            return configuration
        }
        return super.makeContentConfiguration()
    }
    
    override func didSelectRowInTableView() {
        switch block.content {
        case let .link(linkContent):
            router?.showPage(with: linkContent.targetBlockID)
        default: return
        }
    }
    
    override func makeContextualMenu() -> BlocksViews.ContextualMenu {
        BlocksViews.ContextualMenu(title: "",
                                   children: [.create(action: .general(.addBlockBelow)),
                                              .create(action: .general(.delete)),
                                              .create(action: .general(.duplicate))])
    }
}
