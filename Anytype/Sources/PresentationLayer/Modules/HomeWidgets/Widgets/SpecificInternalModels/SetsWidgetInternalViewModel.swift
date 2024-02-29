import Foundation
import Services
import Combine
import UIKit

@MainActor
final class SetsWidgetInternalViewModel: WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let widgetBlockId: String
    private let widgetObject: BaseDocumentProtocol
    private let setsSubscriptionService: SetsSubscriptionServiceProtocol
    private let objectService: ObjectActionsServiceProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State
    
    @Published private var details: [ObjectDetails]?
    @Published private var name: String = Loc.sets
    private var subscriptions = [AnyCancellable]()
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    var allowCreateObject = true
    
    init(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        setsSubscriptionService: SetsSubscriptionServiceProtocol,
        objectService: ObjectActionsServiceProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.setsSubscriptionService = setsSubscriptionService
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
    
    func startHeaderSubscription() {}
    
    func screenData() -> EditorScreenData? {
        return .sets
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return .sets
    }
    
    func onCreateObjectTap() {
        Task {
            let details = try await objectService.createObject(
                name: "",
                typeUniqueKey: .set,
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
        await setsSubscriptionService.startSubscription(
            objectLimit: widgetInfo.fixedLimit,
            update: { [weak self] details in
                self?.details = details
            }
        )
    }
}
