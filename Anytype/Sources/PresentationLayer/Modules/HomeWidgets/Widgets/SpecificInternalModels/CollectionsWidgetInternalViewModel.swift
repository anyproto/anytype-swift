import Foundation
import Services
import Combine
import UIKit

@MainActor
final class CollectionsWidgetInternalViewModel: CommonWidgetInternalViewModel, WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let subscriptionService: CollectionsSubscriptionServiceProtocol
    private let objectService: ObjectActionsServiceProtocol
    private weak var output: CommonWidgetModuleOutput?

    // MARK: - State
    
    @Published private var details: [ObjectDetails]?
    @Published private var name: String = Loc.collections
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    var allowCreateObject = true
    
    init(
        widgetBlockId: BlockId,
        widgetObject: BaseDocumentProtocol,
        subscriptionService: CollectionsSubscriptionServiceProtocol,
        objectService: ObjectActionsServiceProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.subscriptionService = subscriptionService
        self.objectService = objectService
        self.output = output
        super.init(widgetBlockId: widgetBlockId, widgetObject: widgetObject)
    }
    
    // MARK: - WidgetInternalViewModelProtocol
    
    override func startContentSubscription() async {
        await super.startContentSubscription()
        await updateSubscription()
    }
    
    override func stopContentSubscription() async {
        await super.stopContentSubscription()
        await subscriptionService.stopSubscription()
    }
    
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
    
    // MARK: - CommonWidgetInternalViewModel oveerides
    
    override func widgetInfoUpdated() {
        super.widgetInfoUpdated()
        Task {
            await updateSubscription()
        }
    }
    
    // MARK: - Private func
    
    private func updateSubscription() async {
        guard let widgetInfo, contentIsAppear else { return }
        await subscriptionService.startSubscription(objectLimit: widgetInfo.fixedLimit) { [weak self] details in
            self?.details = details
        }
    }
}
