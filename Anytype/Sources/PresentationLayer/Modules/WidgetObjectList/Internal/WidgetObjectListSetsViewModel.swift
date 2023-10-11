import Foundation
import Services
import Combine

final class WidgetObjectListSetsViewModel: WidgetObjectListInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let setsSubscriptionService: SetsSubscriptionServiceProtocol
    
    // MARK: - State
    
    let title = Loc.sets
    let editorScreenData: EditorScreenData = .sets
    var rowDetailsPublisher: AnyPublisher<[WidgetObjectListDetailsData], Never> { $rowDetails.eraseToAnyPublisher()}
    let editMode: WidgetObjectListEditMode = .normal(allowDnd: false)
    
    private var details: [ObjectDetails] = [] {
        didSet { rowDetails = [WidgetObjectListDetailsData(details: details)] }
    }
    @Published private var rowDetails: [WidgetObjectListDetailsData] = []
    
    init(setsSubscriptionService: SetsSubscriptionServiceProtocol) {
        self.setsSubscriptionService = setsSubscriptionService
    }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        Task {
            await setsSubscriptionService.startSubscription(objectLimit: nil) { [weak self] details in
                self?.details = details
            }
        }
    }
    
    func onDisappear() {
        Task {
            await setsSubscriptionService.stopSubscription()
        }
    }
}
