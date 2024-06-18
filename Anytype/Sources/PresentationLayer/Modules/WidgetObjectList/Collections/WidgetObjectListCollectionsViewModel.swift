import Foundation
import Services
import Combine

@MainActor
final class WidgetObjectListCollectionsViewModel: WidgetObjectListInternalViewModelProtocol {
    
    // MARK: - DI
    
    @Injected(\.collectionsSubscriptionService)
    private var subscriptionService: CollectionsSubscriptionServiceProtocol
    
    // MARK: - State
    
    let title = Loc.collections
    let editorScreenData: EditorScreenData = .collections
    var rowDetailsPublisher: AnyPublisher<[WidgetObjectListDetailsData], Never> { $rowDetails.eraseToAnyPublisher()}
    let editMode: WidgetObjectListEditMode = .normal(allowDnd: false)
    
    private var details: [ObjectDetails] = [] {
        didSet { rowDetails = [WidgetObjectListDetailsData(details: details)] }
    }
    @Published private var rowDetails: [WidgetObjectListDetailsData] = []
    
    init() { }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        Task {
            await subscriptionService.startSubscription(objectLimit: nil) { [weak self] details in
                guard let self else { return }
                rowDetails = [WidgetObjectListDetailsData(details: details)]
            }
        }
    }
    
    func onDisappear() {
        Task {
            await subscriptionService.stopSubscription()
        }
    }
}
