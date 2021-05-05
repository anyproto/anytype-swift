import Combine
import Foundation

final class HomeViewModel: ObservableObject {
    @Published var cellData: [PageCellData] = []
    let coordinator: OldHomeCoordinator = ServiceLocator.shared.homeCoordinator()
    
    var cellSubscriptions = [AnyCancellable]()

    private let dashboardService: DashboardServiceProtocol = ServiceLocator.shared.dashboardService()
    private let blockActionsService: BlockActionsServiceSingleProtocol = ServiceLocator.shared.blockActionsServiceSingle()
    
    private var subscriptions = [AnyCancellable]()
            
    private let dashboardModel: DocumentViewModelProtocol = DocumentViewModel()
    
    // MARK: - Public
    func fetchDashboardData() {        
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

    // MARK: - Private
    private func onOpenDashboard(_ serviceSuccess: ServiceSuccess) {
        self.dashboardModel.updatePublisher()
            .reciveOnMain()
            .sink { [weak self] updateResult in
                self?.updateCellData(viewModels: updateResult.models.compactMap({$0 as? BlockPageLinkViewModel}))
            }.store(in: &self.subscriptions)
        self.dashboardModel.open(serviceSuccess)
    }
}
