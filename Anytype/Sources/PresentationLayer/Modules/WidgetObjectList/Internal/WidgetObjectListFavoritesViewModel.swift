import Foundation
import BlocksModels
import Combine

final class WidgetObjectListFavoritesViewModel: WidgetObjectListInternalViewModelProtocol {
    
    private enum Constants {
        static let sectionId = "Favorite"
    }
    
    // MARK: - DI
    
    private let favoriteSubscriptionService: FavoriteSubscriptionServiceProtocol
    private let objectActionService: ObjectActionsServiceProtocol
    
    // MARK: - State
    
    let title = Loc.favorites
    let editorViewType: EditorViewType = .favorites
    var rowDetailsPublisher: AnyPublisher<[WidgetObjectListDetailsData], Never> { $rowDetails.eraseToAnyPublisher() }
    let editMode: WidgetObjectListEditMode = .normal(allowDnd: true)
    
    @Published private var rowDetails: [WidgetObjectListDetailsData] = []
    private var homeDocument: BaseDocumentProtocol
    private var details: [FavoriteBlockDetails] = [] {
        didSet { rowDetails = [WidgetObjectListDetailsData(id: Constants.sectionId, details: details.map(\.details))] }
    }
    
    init(
        favoriteSubscriptionService: FavoriteSubscriptionServiceProtocol,
        accountManager: AccountManagerProtocol,
        documentService: DocumentServiceProtocol,
        objectActionService: ObjectActionsServiceProtocol
    ) {
        self.favoriteSubscriptionService = favoriteSubscriptionService
        self.homeDocument = documentService.document(objectId: accountManager.account.info.homeObjectID)
        self.objectActionService = objectActionService
    }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        favoriteSubscriptionService.startSubscription(homeDocument: homeDocument, objectLimit: nil, update: { [weak self] details in
            self?.details = details
        })
    }
    
    func onDisappear() {
        favoriteSubscriptionService.stopSubscription()
    }
    
    func onMove(from: IndexSet, to: Int) {
        guard let fromIndex = from.first else { return }
        
        let toIndex = to > fromIndex ? to - 1 : to

        guard fromIndex != toIndex, fromIndex < details.count, toIndex < details.count else { return }
        let firstDetails = details[fromIndex]
        let toDetails = details[toIndex]
                
        Task {
            try? await objectActionService.move(
                dashboadId: homeDocument.objectId,
                blockId: firstDetails.blockId,
                dropPositionblockId: toDetails.blockId,
                position: to > fromIndex ? .bottom : .top
            )
        }
    }
    
    func subtitle(for details: ObjectDetails) -> String? {
        return details.subtitle
    }
}
