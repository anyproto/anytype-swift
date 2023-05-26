import Foundation
import Services
import Combine

final class FavoriteWidgetInternalViewModel: WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let favoriteSubscriptionService: FavoriteSubscriptionServiceProtocol
    private let context: WidgetInternalViewModelContext
    
    // MARK: - State
    
    private var document: BaseDocumentProtocol
    @Published private var details: [ObjectDetails]?
    @Published private var name: String = Loc.favorites
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    
    init(
        favoriteSubscriptionService: FavoriteSubscriptionServiceProtocol,
        accountManager: AccountManagerProtocol,
        documentService: DocumentServiceProtocol,
        context: WidgetInternalViewModelContext
    ) {
        self.favoriteSubscriptionService = favoriteSubscriptionService
        self.context = context
        self.document = documentService.document(objectId: accountManager.account.info.homeObjectID)
    }
    
    // MARK: - WidgetInternalViewModelProtocol
    
    func startHeaderSubscription() {}
    
    func stopHeaderSubscription() {}
    
    func startContentSubscription() {
        favoriteSubscriptionService.startSubscription(
            homeDocument: document,
            objectLimit: context.maxItems,
            update: { [weak self] blocks in
                self?.details = blocks.map { $0.details }
            }
        )
    }
    
    func stopContentSubscription() {
        favoriteSubscriptionService.stopSubscription()
    }
    
    func screenData() -> EditorScreenData? {
        return EditorScreenData(pageId: "", type: .favorites)
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return .favorites
    }
}
