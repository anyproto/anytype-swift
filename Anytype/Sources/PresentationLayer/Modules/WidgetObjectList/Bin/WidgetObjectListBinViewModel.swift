import Foundation
import Services
import Combine
import AnytypeCore

@MainActor
final class WidgetObjectListBinViewModel: WidgetObjectListInternalViewModelProtocol {
    
    // MARK: - DI
    
    private let spaceId: String
    @Injected(\.binSubscriptionService)
    private var binSubscriptionService: any BinSubscriptionServiceProtocol
    
    // MARK: - State
    
    let title = Loc.bin
    let emptyStateData = WidgetObjectListEmptyStateData(
        title: Loc.EmptyView.Bin.title,
        subtitle: Loc.EmptyView.Bin.subtitle
    )
    let editorScreenData: EditorScreenData
    var rowDetailsPublisher: AnyPublisher<[WidgetObjectListDetailsData], Never> { $rowDetails.eraseToAnyPublisher()}
    let editMode: WidgetObjectListEditMode = .normal(allowDnd: false)
    let availableMenuItems: [WidgetObjectListMenuItem] = [.restore, .delete]
    
    private var details: [ObjectDetails] = [] {
        didSet { rowDetails = [WidgetObjectListDetailsData(details: details)] }
    }
    @Published private var rowDetails: [WidgetObjectListDetailsData] = []
    
    init(spaceId: String) {
        self.spaceId = spaceId
        self.editorScreenData = .bin(spaceId: spaceId)
    }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        Task {
            await binSubscriptionService.startSubscription(spaceId: spaceId, objectLimit: nil) { [weak self] details in
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
        return details.objectType.displayName
    }
}
