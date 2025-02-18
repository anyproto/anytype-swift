import Foundation
import Services
import Combine
import UIKit

@MainActor
final class FavoriteWidgetInternalViewModel: ObservableObject, WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let widgetBlockId: String
    private let widgetObject: any BaseDocumentProtocol
    private let homeObjectId: String
    private let spaceId: String
    private weak var output: (any CommonWidgetModuleOutput)?
    
    @Injected(\.favoriteSubscriptionService)
    private var favoriteSubscriptionService: any FavoriteSubscriptionServiceProtocol
    @Injected(\.defaultObjectCreationService)
    private var defaultObjectService: any DefaultObjectCreationServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    
    // MARK: - State
    
    private let document: any BaseDocumentProtocol
    @Published private var details: [ObjectDetails]?
    @Published private var name: String = Loc.favorites
    private var subscriptions = [AnyCancellable]()
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    var allowCreateObject = true
    
    init(data: WidgetSubmoduleData) {
        self.widgetBlockId = data.widgetBlockId
        self.widgetObject = data.widgetObject
        self.homeObjectId = data.workspaceInfo.homeObjectID
        self.spaceId = data.workspaceInfo.accountSpaceId
        self.output = data.output
        
        let documentService = Container.shared.openedDocumentProvider.resolve()
        self.document = documentService.document(objectId: homeObjectId, spaceId: spaceId)
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
    
    func screenData() -> ScreenData? {
        return .editor(.favorites(homeObjectId: homeObjectId, spaceId: spaceId))
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
            output?.onObjectSelected(screenData: details.screenData())
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
