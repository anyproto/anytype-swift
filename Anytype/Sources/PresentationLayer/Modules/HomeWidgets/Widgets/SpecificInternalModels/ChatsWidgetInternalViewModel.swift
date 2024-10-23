import Foundation
import Services
import Combine
import UIKit

@MainActor
final class ChatsWidgetInternalViewModel: ObservableObject, WidgetInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let widgetBlockId: String
    private let widgetObject: any BaseDocumentProtocol
    private let spaceId: String
    private weak var output: (any CommonWidgetModuleOutput)?
    
    @Injected(\.chatsSubscriptionService)
    private var chatsSubscriptionService: any ChatsSubscriptionServiceProtocol
    @Injected(\.objectActionsService)
    private var objectService: any ObjectActionsServiceProtocol
    
    // MARK: - State
    
    @Published private var details: [ObjectDetails]?
    @Published private var name: String = Loc.Widgets.Library.Chat.name
    private var subscriptions = [AnyCancellable]()
    
    var detailsPublisher: AnyPublisher<[ObjectDetails]?, Never> { $details.eraseToAnyPublisher() }
    var namePublisher: AnyPublisher<String, Never> { $name.eraseToAnyPublisher() }
    var allowCreateObject = true
    
    init(data: WidgetSubmoduleData) {
        self.widgetBlockId = data.widgetBlockId
        self.widgetObject = data.widgetObject
        self.spaceId = data.workspaceInfo.accountSpaceId
        self.output = data.output
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
        return .chats(spaceId: spaceId)
    }
    
    func analyticsSource() -> AnalyticsWidgetSource {
        return .chat
    }
    
    func onCreateObjectTap() {
        Task {
            let details = try await objectService.createObject(
                name: "",
                typeUniqueKey: .chat,
                shouldDeleteEmptyObject: true,
                shouldSelectType: false,
                shouldSelectTemplate: false,
                spaceId: widgetObject.spaceId,
                origin: .none,
                templateId: nil
            )
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: .widget)
            output?.onObjectSelected(screenData: details.editorScreenData())
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    // MARK: - Private func
    
    private func updateSubscription(widgetInfo: BlockWidgetInfo) async {
        await chatsSubscriptionService.startSubscription(
            spaceId: spaceId,
            objectLimit: widgetInfo.fixedLimit,
            update: { [weak self] details in
                self?.details = details
            }
        )
    }
}
