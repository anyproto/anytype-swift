import Foundation
import Services
import Combine
import AnytypeCore

@MainActor
final class WidgetObjectListBinViewModel: WidgetObjectListInternalViewModelProtocol {
    
    // MARK: - DI
    
    @Injected(\.binSubscriptionService)
    private var binSubscriptionService: BinSubscriptionServiceProtocol
    
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
    
    init() { }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        Task {
            await binSubscriptionService.startSubscription(objectLimit: nil) { [weak self] details in
                self?.details = details
            }
        }
    }
    
    func onDisappear() {
        Task {
            await binSubscriptionService.stopSubscription()
        }
    }
    
    func subtitle(for details: ObjectDetails) -> String? {
        return details.subtitle
    }
}
