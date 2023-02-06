import Foundation
import BlocksModels
import Combine

final class WidgetObjectListSetsViewModel: ObservableObject, WidgetObjectListInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let setsSubscriptionService: SetsSubscriptionServiceProtocol
    
    // MARK: - State
    
    let title = Loc.sets
    let editorViewType: EditorViewType = .sets
    let showType: Bool = false
    var rowDetailsPublisher: AnyPublisher<[ObjectDetails], Never> {
        $rowDetails.eraseToAnyPublisher()
    }
    
    @Published private var rowDetails: [ObjectDetails] = []
    
    init(setsSubscriptionService: SetsSubscriptionServiceProtocol) {
        self.setsSubscriptionService = setsSubscriptionService
    }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        setsSubscriptionService.startSubscription(objectLimit: nil, update: { [weak self] _, update in
            self?.rowDetails.applySubscriptionUpdate(update)
        })
    }
    
    func onDisappear() {
        setsSubscriptionService.stopSubscription()
    }
}
