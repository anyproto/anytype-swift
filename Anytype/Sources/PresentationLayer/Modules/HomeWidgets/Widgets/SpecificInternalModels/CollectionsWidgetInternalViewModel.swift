import Foundation
import Services
import Combine
import UIKit

@MainActor
final class CollectionsWidgetInternalViewModel: WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let widgetBlockId: String
    private let widgetObject: BaseDocumentProtocol
    private let subscriptionService: CollectionsSubscriptionServiceProtocol
    private let objectService: ObjectActionsServiceProtocol
    private weak var output: CommonWidgetModuleOutput?

    // MARK: - State
    
    @Published private var details: [ObjectDetails]?
    @Published private var name: String = Loc.collections
    private var subscriptions = [AnyCancellable]()
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    var allowCreateObject = true
    
    init(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        subscriptionService: CollectionsSubscriptionServiceProtocol,
        objectService: ObjectActionsServiceProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.subscriptionService = subscriptionService
        self.objectService = objectService
        self.output = output
    }
    
    // MARK: - WidgetInternalViewModelProtocol
    
    func startContentSubscription() async {
        widgetObject.blockWidgetInfoPublisher(widgetBlockId: widgetBlockId)
            .receiveOnMain()
            .sink { [weak self] widgetInfo in
                guard let self else { return }
                Task {
                    await self.updateSubscription(widgetInfo: widgetInfo)
                }
            }
            .store(in: &subscriptions)
    }
    
    func stopContentSubscription() async {
        subscriptions.removeAll()
        await subscriptionService.stopSubscription()
    }
    
    func startHeaderSubscription() {}
    
    func stopHeaderSubscription() {}
    
    func screenData() -> EditorScreenData? {
        return .collections
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return .collections
    }
    
    func onCreateObjectTap() {
        Task {
            let details = try await objectService.createObject(
                name: "",
                typeUniqueKey: .collection,
                shouldDeleteEmptyObject: true,
                shouldSelectType: false,
                shouldSelectTemplate: false,
                spaceId: widgetObject.spaceId,
                origin: .none,
                templateId: nil
            )
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, route: .widget)
            output?.onObjectSelected(screenData: details.editorScreenData())
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    // MARK: - Private func
    
    private func updateSubscription(widgetInfo: BlockWidgetInfo) async {
        await subscriptionService.startSubscription(objectLimit: widgetInfo.fixedLimit) { [weak self] details in
            self?.details = details
        }
    }
}
