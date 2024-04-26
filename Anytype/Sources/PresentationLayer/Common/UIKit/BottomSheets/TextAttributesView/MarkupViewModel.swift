import AnytypeCore
import Services
import Foundation
import Combine

@MainActor
final class MarkupViewModel: MarkupViewModelProtocol {
    weak var view: MarkupViewProtocol?

    private var cancellable: AnyCancellable? = nil
    
    private let blockIds: [BlockId]
    private let actionHandler: BlockActionHandlerProtocol
    private let document: BaseDocumentProtocol
    private let linkToObjectCoordinator: LinkToObjectCoordinatorProtocol
    
    // For read link value
    private var selectedMarkups: [MarkupType: AttributeState] = [:]
    
    init(
        document: BaseDocumentProtocol,
        blockIds: [BlockId],
        actionHandler: BlockActionHandlerProtocol,
        linkToObjectCoordinator: LinkToObjectCoordinatorProtocol
    ) {
        self.document = document
        self.blockIds = blockIds
        self.actionHandler = actionHandler
        self.linkToObjectCoordinator = linkToObjectCoordinator
    }

    // MARK: - MarkupViewModelProtocol
    
    func handle(action: MarupViewAction) {
        switch action {
        case .toggleMarkup(let markupType):
            handleMarkup(markupType)
        case .selectAlignment(let layoutAlignment):
            handleAlignment(layoutAlignment)
        }
    }

    func viewLoaded() {
        subscribeToPublishers()
        updateState()
    }
    
    // MARK: - Private
    
    private func handleMarkup(_ markup: MarkupViewType) {
        switch markup {
        case .bold:
            actionHandler.changeMarkup(blockIds: blockIds, markType: .bold)
        case .italic:
            actionHandler.changeMarkup(blockIds: blockIds, markType: .italic)
        case .keyboard:
            actionHandler.changeMarkup(blockIds: blockIds, markType: .keyboard)
        case .strikethrough:
            actionHandler.changeMarkup(blockIds: blockIds, markType: .strikethrough)
        case .link:
            let urlLink = selectedMarkups.keys.compactMap { $0.urlLink }.first
            let blokcLink = selectedMarkups.keys.compactMap { $0.blokcLink }.first
            let currentLink = Either.from(left: urlLink, right: blokcLink)
            
            linkToObjectCoordinator.startFlow(
                spaceId: document.spaceId,
                currentLink: currentLink,
                setLinkToObject: { [weak self, blockIds] blockId in
                    self?.actionHandler.changeMarkup(blockIds: blockIds, markType: .linkToObject(blockId))
                },
                setLinkToUrl: { [weak self, blockIds] url in
                    self?.actionHandler.changeMarkup(blockIds: blockIds, markType: .link(url))
                },
                removeLink: { [weak self, blockIds] in
                    switch currentLink {
                    case .right:
                        self?.actionHandler.changeMarkup(blockIds: blockIds, markType: .linkToObject(nil))
                    case .left:
                        self?.actionHandler.changeMarkup(blockIds: blockIds, markType: .link(nil))
                    case .none:
                        break
                    }
                },
                willShowNextScreen: { [weak self] in
                    self?.view?.dismiss()
                }
            )
        }
    }
    
    private func handleAlignment(_ alignment: LayoutAlignment) {
        actionHandler.setAlignment(alignment, blockIds: blockIds)
    }
    
    private func subscribeToPublishers() {
        cancellable =  document.updatePublisher.sink { [weak self] _ in
            self?.updateState()
        }
    }
    
    private func updateState() {
        let info = blockIds.compactMap { document.infoContainer.get(id: $0) }
    
        displayCurrentState(
            selectedMarkups: AttributeState.markupAttributes(document: document, infos: info),
            selectedHorizontalAlignment: AttributeState.alignmentAttributes(from: info)
        )
    }

    private func displayCurrentState(
        selectedMarkups: [MarkupType: AttributeState],
        selectedHorizontalAlignment: [LayoutAlignment: AttributeState]
    ) {
        self.selectedMarkups = selectedMarkups
        
        let displayMarkups: [MarkupViewType: AttributeState] = selectedMarkups.reduce(into: [:])
        { partialResult, item in
            guard let key = item.key.toMarkupViewType else { return }
            partialResult[key] = item.value
        }
        
        let displayState = MarkupViewsState(
            markup: displayMarkups,
            alignment: selectedHorizontalAlignment
        )
        
        view?.setMarkupState(displayState)
    }
}


fileprivate extension MarkupType {
    
    var urlLink: URL? {
        switch self {
        case let .link(url):
            return url
        default:
            return nil
        }
    }
    
    var blokcLink: BlockId? {
        switch self {
        case let .linkToObject(blokcId):
            return blokcId
        default:
            return nil
        }
    }
}
