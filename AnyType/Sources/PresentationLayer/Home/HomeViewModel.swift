
import BlocksModels
import Combine
import Foundation
import ProtobufMessages

extension HomeViewModel {
    struct NewPageData {
        let pageId: String
        var showingNewPage: Bool
    }
}

final class HomeViewModel: ObservableObject {
    @Published var cellData: [PageCellData] = []
    @Published var newPageData = NewPageData(pageId: "", showingNewPage: false)
    let coordinator: HomeCoordinator = ServiceLocator.shared.homeCoordinator()
    
    var cellSubscriptions = [AnyCancellable]()

    private let dashboardService: DashboardServiceProtocol = ServiceLocator.shared.dashboardService()
    private let blockActionsService: BlockActionsServiceSingleProtocol = ServiceLocator.shared.blockActionsServiceSingle()
    
    private var subscriptions = [AnyCancellable]()
    private var newPageSubscription: AnyCancellable?
            
    private let dashboardModel: DocumentViewModelProtocol = DocumentViewModel()
    
    init() {
        fetchDashboardData()
    }
    
    // MARK: - Public
    private func fetchDashboardData() {        
        dashboardService.openDashboard().sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished: return
                case let .failure(error):
                    assertionFailure("Subscribe dashboard events error \(error)")
                }
            }
        ) { [weak self] serviceSuccess in
            self?.onOpenDashboard(serviceSuccess)
        }.store(in: &self.subscriptions)
    }
    
    func createNewPage() {
        guard let rootId = self.dashboardModel.documentId else { return }
        newPageSubscription = dashboardService.createNewPage(contextId: rootId).receiveOnMain().sink(receiveCompletion: { result in
            switch result {
            case .finished: return
            case let .failure(error):
                assertionFailure("Create page error \(error)")
            }
        }) { [weak self] success in
            guard let self = self else {
                return
            }
            
            self.dashboardModel.handle(events: .init(contextId: success.contextID, events: success.messages))
            
            guard let newBlockId = self.extractNewBlockId(serviceSuccess: success) else {
                assertionFailure("No new block id in create new page response")
                return
            }
            
            self.newPageData = NewPageData(pageId: newBlockId, showingNewPage: true)
        }
    }
    
    private func extractNewBlockId(serviceSuccess: ServiceSuccess) -> String? {
        let blockAdd = serviceSuccess.messages.compactMap { message -> Anytype_Event.Block.Add?  in
            if case let .blockAdd(value)? = message.value {
                return value
            }
            
            return nil
        }.first
        
        return blockAdd?.blocks.first?.link.targetBlockID
    }
    
    private func onOpenDashboard(_ serviceSuccess: ServiceSuccess) {
        dashboardModel.updatePublisher()
            .sink { [weak self] updateResult in
                self?.onDashboardUpdate(updateResult)
            }.store(in: &self.subscriptions)
        dashboardModel.open(serviceSuccess)
    }
}
