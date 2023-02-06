import Foundation
import BlocksModels
import Combine

final class WidgetObjectListFavoritesViewModel: ObservableObject, WidgetObjectListInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let favoriteSubscriptionService: FavoriteSubscriptionServiceProtocol
    
    // MARK: - State
    
    var title = Loc.favorites
    var editorViewType: EditorViewType = .favorites
    var rowDetailsPublisher: AnyPublisher<[ObjectDetails], Never> {
        $rowDetails.eraseToAnyPublisher()
    }
    
    @Published private var rowDetails: [ObjectDetails] = []
    
    private var homeDocument: BaseDocumentProtocol
    
    init(
        favoriteSubscriptionService: FavoriteSubscriptionServiceProtocol,
        accountManager: AccountManagerProtocol,
        documentService: DocumentServiceProtocol
    ) {
        self.favoriteSubscriptionService = favoriteSubscriptionService
        self.homeDocument = documentService.document(objectId: accountManager.account.info.homeObjectID)
    }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        favoriteSubscriptionService.startSubscription(homeDocument: homeDocument, objectLimit: nil, update: { [weak self] details in
            self?.rowDetails = details
        })
    }
    
    func onDisappear() {
        favoriteSubscriptionService.stopSubscription()
    }
}
