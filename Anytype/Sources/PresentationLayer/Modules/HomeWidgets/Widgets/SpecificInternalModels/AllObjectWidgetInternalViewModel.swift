import Foundation
import Services
import Combine
import UIKit

@MainActor
final class AllObjectWidgetInternalViewModel: ObservableObject, WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let widgetBlockId: String
    private let widgetObject: any BaseDocumentProtocol
    private let spaceId: String
    private weak var output: (any CommonWidgetModuleOutput)?
    private let type: AllObjectWidgetType
    
    @Injected(\.allContentSubscriptionService)
    private var allContentSubscriptionService: any AllContentSubscriptionServiceProtocol
    
    // MARK: - State
    
    @Published private var details: [ObjectDetails]?
    @Published private var name: String
    private var subscriptions = [AnyCancellable]()
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    var allowCreateObject = false
    
    init(data: WidgetSubmoduleData, type: AllObjectWidgetType) {
        self.widgetBlockId = data.widgetBlockId
        self.widgetObject = data.widgetObject
        self.spaceId = data.workspaceInfo.accountSpaceId
        self.output = data.output
        self.type = type
        self.name = type.name
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
    
    func screenData() -> ScreenData? {
        return .editor(type.editorScreenData(spaceId: spaceId))
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return type.analyticsWidgetSource
    }
    
    // MARK: - Private func
    
    private func updateSubscription(widgetInfo: BlockWidgetInfo) async {
        await allContentSubscriptionService.stopSubscription()
        await allContentSubscriptionService.startSubscription(
            spaceId: spaceId,
            section: type.typeSection,
            sort: ObjectSort(relation: .dateUpdated),
            onlyUnlinked: false,
            limitedObjectsIds: nil,
            limit: widgetInfo.fixedLimit,
            update: { [weak self] details, _ in
                self?.details = details
            }
        )
    }
}
