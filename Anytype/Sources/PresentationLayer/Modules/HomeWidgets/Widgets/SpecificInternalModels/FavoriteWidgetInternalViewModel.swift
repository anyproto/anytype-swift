import Foundation
import Services
import Combine
import UIKit

@MainActor
final class FavoriteWidgetInternalViewModel: CommonWidgetInternalViewModel, WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let favoriteSubscriptionService: FavoriteSubscriptionServiceProtocol
    private let defaultObjectService: DefaultObjectCreationServiceProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State
    
    private let document: BaseDocumentProtocol
    @Published private var details: [ObjectDetails]?
    @Published private var name: String = Loc.favorites
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    var allowCreateObject = true
    
    init(
        widgetBlockId: BlockId,
        widgetObject: BaseDocumentProtocol,
        favoriteSubscriptionService: FavoriteSubscriptionServiceProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        documentService: OpenedDocumentsProviderProtocol,
        defaultObjectService: DefaultObjectCreationServiceProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.favoriteSubscriptionService = favoriteSubscriptionService
        self.document = documentService.document(objectId: activeWorkspaceStorage.workspaceInfo.homeObjectID)
        self.defaultObjectService = defaultObjectService
        self.objectActionsService = objectActionsService
        self.output = output
        super.init(widgetBlockId: widgetBlockId, widgetObject: widgetObject)
    }
    
    // MARK: - WidgetInternalViewModelProtocol
    
    override func startContentSubscription() async {
        await super.startContentSubscription()
        updateSubscription()
    }
    
    override func stopContentSubscription() async {
        await super.stopContentSubscription()
        favoriteSubscriptionService.stopSubscription()
    }
    
    func screenData() -> EditorScreenData? {
        return .favorites
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return .favorites
    }
    
    func onCreateObjectTap() {
        Task {
            let details = try await defaultObjectService.createDefaultObject(name: "", shouldDeleteEmptyObject: true, spaceId: widgetObject.spaceId)
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, route: .widget)
            AnytypeAnalytics.instance().logAddToFavorites(true)
            try await objectActionsService.setFavorite(objectIds: [details.id], true)
            output?.onObjectSelected(screenData: details.editorScreenData())
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    // MARK: - CommonWidgetInternalViewModel oveerides
    
    override func widgetInfoUpdated() {
        super.widgetInfoUpdated()
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
