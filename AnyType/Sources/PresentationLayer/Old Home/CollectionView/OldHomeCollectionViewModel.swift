import Foundation
import Combine
import SwiftUI
import os
import BlocksModels


enum OldHomeCollectionViewCellType: Hashable {
    case plus
    case document(OldHomeCollectionViewDocumentCellModel)
}

class OldHomeCollectionViewModel: ObservableObject {
    private let dashboardService: DashboardServiceProtocol
    private let blockActionsService: BlockActionsServiceSingleProtocol
    
    private var subscriptions: Set<AnyCancellable> = []
            
    @Published var cellViewModels: [OldHomeCollectionViewCellType] = []
    private let documentViewModel: DocumentViewModelProtocol = DocumentViewModel()
    
    var userActionsPublisher: AnyPublisher<UserAction, Never> = .empty()
    private var userActionsSubject: PassthroughSubject<UserAction, Never> = .init()
    
    typealias CellUserAction = OldHomeCollectionViewDocumentCellModel.UserActionPayload
    private var cellUserActionSubject: PassthroughSubject<CellUserAction, Never> = .init()
    
    init(
        dashboardService: DashboardServiceProtocol,
        blockActionsService: BlockActionsServiceSingleProtocol
    ) {
        self.dashboardService = dashboardService
        self.blockActionsService = blockActionsService
        
        self.setupSubscribers()
        self.setupDashboard()
    }
    
    // MARK: - Setup
    func setupDashboard() {
        self.dashboardService.openDashboard().reciveOnMain().sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished: return
                case let .failure(error):
                    assertionFailure("Subscribe dashboard events error \(error)")
                }
            }
        ) { [weak self] value in
            self?.handleOpenDashboard(value)
        }.store(in: &self.subscriptions)
    }
    
    func setupSubscribers() {
        self.userActionsPublisher = self.userActionsSubject.eraseToAnyPublisher()
        
        self.cellUserActionSubject.map { value -> UserEvent in
            switch value.action {
            case .remove: return .contextualMenu(.init(model: value.model, action: .editBlock(.delete)))
            }
        }.sink { [weak self] (value) in
            self?.receiveUserEvent(value)
        }.store(in: &self.subscriptions)
    }
    
    /// We should add caching, otherwise, we will miss updates from long-playing views as file uploading or downloading views.
    private func rebuildViewModels(builders: [BlockViewBuilderProtocol]) {
        let newBuilders = builders.compactMap({$0 as? BlockPageLinkViewModel})
        self.createViewModels(from: newBuilders)
    }

    func handleOpenDashboard(_ value: ServiceSuccess) {
        self.documentViewModel.updatePublisher().sink { [weak self] (updateResult) in
            switch updateResult.updates {
                case .update(.empty): return
                default: break
            }
            
            DispatchQueue.main.async {
                self?.rebuildViewModels(builders: updateResult.models)
                switch updateResult.updates {
                case let .update(value):
                    if !value.addedIds.isEmpty, let id = value.addedIds.first {
                        self?.openPage(with: id)
                    }
                case .general:
                    return
                }
            }
        }.store(in: &self.subscriptions)
        self.documentViewModel.open(value)
    }
    
    /// TODO: Add
    /// Add interaction handlers?
    ///
    func removePage(with id: BlockId) {
        guard let rootId = self.documentViewModel.documentId else { return }
//        guard let targetModel = self.rootModel?.blocksContainer.choose(by: id) else { return }
//        let blockId = targetModel.blockModel.information.id
        let blockId = id
        self.blockActionsService.delete(contextID: rootId, blockIds: [blockId]).sink { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                assertionFailure("Remove page error \(error)")
            }
        } receiveValue: { [weak self] value in
            self?.documentViewModel.handle(events: .init(contextId: value.contextID, events: value.messages))
        }.store(in: &self.subscriptions)
    }
    
    func openPage(with id: BlockId) {
//        guard let targetModel = self.rootModel?.blocksContainer.choose(by: id) else { return }
//        guard case let .link(link) = targetModel.blockModel.information.content else { return }

//        let blockId = link.targetBlockID
        self.send(.showPage(id))
    }
    
    func didSelectPage(with index: IndexPath) {
        switch self.cellViewModels[index.row] {
        case let .document(value):
            self.openPage(with: value.page.targetBlockId)
        case .plus:
            guard let rootId = self.documentViewModel.documentId else { return }
            self.dashboardService.createNewPage(contextId: rootId).sink(receiveCompletion: { result in
                switch result {
                case .finished: return
                case let .failure(error):
                    assertionFailure("Create page error \(error)")
                }
            }) { [weak self] value in
                self?.documentViewModel.handle(events: .init(contextId: value.contextID, events: value.messages))
            }.store(in: &self.subscriptions)
        }
    }
    
    
    // MARK: - Private
    private func createViewModels(from pages: [BlockPageLinkViewModel]) {
        let links = pages.compactMap({ pageLink -> OldHomeCollectionViewDocumentCellModel? in
            let detailsModel = pageLink.getDetailsViewModel()

            let details = detailsModel.currentDetails
            let targetBlockId: String
            if case let .link(link) = pageLink.getBlock().blockModel.information.content {
                targetBlockId = link.targetBlockID
            }
            else {
                targetBlockId = ""
            }
            let model = OldHomeCollectionViewDocumentCellModel(
                page: .init(id: pageLink.blockId, targetBlockId: targetBlockId),
                title: details.title?.value ?? "",
                image: nil, emoji: details.iconEmoji?.value
            )

            let accessorPublisher = detailsModel.wholeDetailsPublisher
            let title = accessorPublisher.map { $0.title?.value }.eraseToAnyPublisher()
            let emoji = accessorPublisher.map { $0.iconEmoji?.value}.eraseToAnyPublisher()
            let iconImage = accessorPublisher.map { $0.iconImage?.value}.eraseToAnyPublisher()

            model.configured(titlePublisher: title)
            model.configured(emojiImagePublisher: emoji)
            model.configured(imagePublisher: iconImage)
            model.configured(userActionSubject: self.cellUserActionSubject)
            return model
        }).map(OldHomeCollectionViewCellType.document)
        self.cellViewModels = links + [.plus]
    }
    
    private func send(_ action: UserAction) {
        self.userActionsSubject.send(action)
    }
    
    func receiveUserEvent(_ event: UserEvent) {
        switch event {
        case let .contextualMenu(event):
            switch event.action {
            case .editBlock(.delete): self.removePage(with: event.model)
            default:
                assertionFailure("Skipping event: \(event)\n We are only handling actions above. Do not forget to process all actions.")
            }
        }
    }
}
