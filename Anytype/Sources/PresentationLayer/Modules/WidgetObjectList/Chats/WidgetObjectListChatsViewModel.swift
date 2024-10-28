import Foundation
import Services
import Combine

@MainActor
final class WidgetObjectListChatsViewModel: WidgetObjectListInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let spaceId: String
    @Injected(\.chatsSubscriptionService)
    private var chatsSubscriptionService: any ChatsSubscriptionServiceProtocol
    
    // MARK: - State
    
    let title = Loc.Widgets.Library.Chat.name
    let emptyStateData = WidgetObjectListEmptyStateData(
        title: Loc.EmptyView.Default.title,
        subtitle: Loc.EmptyView.Default.subtitle
    )
    let editorScreenData: EditorScreenData
    var rowDetailsPublisher: AnyPublisher<[WidgetObjectListDetailsData], Never> { $rowDetails.eraseToAnyPublisher()}
    let editMode: WidgetObjectListEditMode = .normal(allowDnd: false)
    
    private var details: [ObjectDetails] = [] {
        didSet { rowDetails = [WidgetObjectListDetailsData(details: details)] }
    }
    @Published private var rowDetails: [WidgetObjectListDetailsData] = []
    
    init(spaceId: String) {
        self.spaceId = spaceId
        self.editorScreenData = .chats(spaceId: spaceId)
    }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        Task {
            await chatsSubscriptionService.startSubscription(spaceId: spaceId, objectLimit: nil) { [weak self] details in
                self?.details = details
            }
        }
    }
    
    func onDisappear() {
        Task {
            await chatsSubscriptionService.stopSubscription()
        }
    }
}
