import Foundation
import Services
import Combine

@MainActor
final class RecentWidgetInternalViewModel: ObservableObject, WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let type: RecentWidgetType
    private let widgetBlockId: String
    private let widgetObject: any BaseDocumentProtocol
    private let spaceId: String
    
    @Injected(\.recentSubscriptionService)
    private var recentSubscriptionService: any RecentSubscriptionServiceProtocol
    
    // MARK: - State
    
    @Published private var details: [ObjectDetails]?
    @Published private var name: String
    private var subscriptions = [AnyCancellable]()
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    
    init(
        data: WidgetSubmoduleData,
        type: RecentWidgetType
    ) {
        self.type = type
        self.widgetBlockId = data.widgetBlockId
        self.widgetObject = data.widgetObject
        self.spaceId = data.spaceInfo.accountSpaceId
        self.name = type.title
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
        return type.analyticsSource
    }
    
    // MARK: - Private func
    
    private func updateSubscription(widgetInfo: BlockWidgetInfo) async {
        await recentSubscriptionService.startSubscription(
            spaceId: spaceId,
            type: type,
            objectLimit: widgetInfo.fixedLimit,
            update: { [weak self] details in
                self?.details = details
            }
        )
    }
}
