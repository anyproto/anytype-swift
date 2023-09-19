import Foundation
import Services
import Combine
import AnytypeCore

final class WidgetObjectListBinViewModel: WidgetObjectListInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let binSubscriptionService: BinSubscriptionServiceProtocol
    
    // MARK: - State
    
    let title = Loc.bin
    let editorScreenData: EditorScreenData = .bin
    var rowDetailsPublisher: AnyPublisher<[WidgetObjectListDetailsData], Never> { $rowDetails.eraseToAnyPublisher()}
    let editMode: WidgetObjectListEditMode = .normal(allowDnd: false)
    let availableMenuItems: [WidgetObjectListMenuItem] = [.restore, .delete]
    
    private var details: [ObjectDetails] = [] {
        didSet { rowDetails = [WidgetObjectListDetailsData(details: details)] }
    }
    @Published private var rowDetails: [WidgetObjectListDetailsData] = []
    
    init(binSubscriptionService: BinSubscriptionServiceProtocol) {
        self.binSubscriptionService = binSubscriptionService
    }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        binSubscriptionService.startSubscription(objectLimit: nil, update: { [weak self] _, update in
            self?.details.applySubscriptionUpdate(update)
        })
    }
    
    func onDisappear() {
        binSubscriptionService.stopSubscription()
    }
    
    func subtitle(for details: ObjectDetails) -> String? {
        return details.subtitle
    }
}
