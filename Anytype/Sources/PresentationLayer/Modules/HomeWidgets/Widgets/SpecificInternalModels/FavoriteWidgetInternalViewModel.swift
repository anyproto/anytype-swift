import Foundation
import Services
import Combine

final class FavoriteWidgetInternalViewModel: CommonWidgetInternalViewModel, WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let favoriteSubscriptionService: FavoriteSubscriptionServiceProtocol
    
    // MARK: - State
    
    private let document: BaseDocumentProtocol
    @Published private var details: [ObjectDetails]?
    @Published private var name: String = Loc.favorites
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    
    init(
        widgetBlockId: BlockId,
        widgetObject: BaseDocumentProtocol,
        favoriteSubscriptionService: FavoriteSubscriptionServiceProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        documentService: DocumentServiceProtocol
    ) {
        self.favoriteSubscriptionService = favoriteSubscriptionService
        self.document = documentService.document(objectId: activeWorkspaceStorage.workspaceInfo.homeObjectID)
        super.init(widgetBlockId: widgetBlockId, widgetObject: widgetObject)
    }
    
    // MARK: - WidgetInternalViewModelProtocol
    
    override func startContentSubscription() {
        super.startContentSubscription()
        updateSubscription()
    }
    
    override func stopContentSubscription() {
        super.stopContentSubscription()
        favoriteSubscriptionService.stopSubscription()
    }
    
    func screenData() -> EditorScreenData? {
        return .favorites
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return .favorites
    }
    
    // MARK: - CommonWidgetInternalViewModel oveerides
    
    override func widgetInfoUpdated() {
        updateSubscription()
    }
    
    // MARK: - Private func
    
    private func updateSubscription() {
        guard let widgetInfo, contentIsAppear else { return }
        favoriteSubscriptionService.stopSubscription()
        favoriteSubscriptionService.startSubscription(
            homeDocument: document,
            objectLimit: widgetInfo.fixedLimit,
            update: { [weak self] blocks in
                self?.details = blocks.map { $0.details }
            }
        )
    }
}
