import Foundation
import Services
import Combine
import UIKit

@MainActor
final class FavoriteWidgetInternalViewModel: WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let widgetBlockId: String
    private let widgetObject: BaseDocumentProtocol
    private let favoriteSubscriptionService: FavoriteSubscriptionServiceProtocol
    private let defaultObjectService: DefaultObjectCreationServiceProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State
    
    private let document: BaseDocumentProtocol
    @Published private var details: [ObjectDetails]?
    @Published private var name: String = Loc.favorites
    private var subscriptions = [AnyCancellable]()
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    var allowCreateObject = true
    
    init(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        favoriteSubscriptionService: FavoriteSubscriptionServiceProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        documentService: OpenedDocumentsProviderProtocol,
        defaultObjectService: DefaultObjectCreationServiceProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.favoriteSubscriptionService = favoriteSubscriptionService
        self.document = documentService.document(objectId: activeWorkspaceStorage.workspaceInfo.homeObjectID)
        self.defaultObjectService = defaultObjectService
        self.objectActionsService = objectActionsService
        self.output = output
    }
    
    // MARK: - WidgetInternalViewModelProtocol
    
    func startContentSubscription() async {
        widgetObject.blockWidgetInfoPublisher(widgetBlockId: widgetBlockId)
            .receiveOnMain()
            .sink { [weak self] widgetInfo in
                guard let self else { return }
                self.updateSubscription(widgetInfo: widgetInfo)
            }
            .store(in: &subscriptions)
    }
    
    func startHeaderSubscription() {}
    
    func screenData() -> EditorScreenData? {
        return .favorites
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return .favorites
    }
    
    func onCreateObjectTap() {
        Task {
            let details = try await defaultObjectService.createDefaultObject(name: "", shouldDeleteEmptyObject: true, spaceId: widgetObject.spaceId)
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: .widget)
            AnytypeAnalytics.instance().logAddToFavorites(true)
            try await objectActionsService.setFavorite(objectIds: [details.id], true)
            output?.onObjectSelected(screenData: details.editorScreenData())
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    // MARK: - Private func
    
    private func updateSubscription(widgetInfo: BlockWidgetInfo) {
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
