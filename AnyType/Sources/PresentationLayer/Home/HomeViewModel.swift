import Combine
import Foundation
import BlocksModels

final class HomeViewModel: ObservableObject {
    private let dashboardService: DashboardServiceProtocol = ServiceLocator.shared.dashboardService()
    private let blockActionsService: BlockActionsServiceSingleProtocol = ServiceLocator.shared.blockActionsServiceSingle()
    
    private var subscriptions: Set<AnyCancellable> = []
            
    private let documentViewModel: DocumentViewModelProtocol = DocumentViewModel()
    
    @Published var cellData: [PageCellData] = []
    
    // MARK: - Public
    func fetchDashboardData() {
        dashboardService.openDashboard().receive(on: DispatchQueue.main).sink(
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
        self.documentViewModel.updatePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updateResult in
                self?.updateCellData(viewModels: updateResult.models.compactMap({$0 as? BlockPageLinkViewModel}))
            }.store(in: &self.subscriptions)
        self.documentViewModel.open(serviceSuccess)
    }
    
    private func updateCellData(viewModels: [BlockPageLinkViewModel]) {
        self.cellData = viewModels.map { pageLinkViewModel in
            let details = pageLinkViewModel.getDetailsViewModel().currentDetails

            return PageCellData(
                id: pageLinkViewModel.blockId,
                iconData: iconData(details: details),
                title: details.title?.value ?? "",
                type: "Page"
            )
        }
    }
    
    private func iconData(details: DetailsInformationProvider) -> PageCellIconData? {
        if let imageId = details.iconImage?.value, !imageId.isEmpty {
            return .imageId(imageId)
        } else if let emoji = details.iconEmoji?.value, !emoji.isEmpty {
            return .emoji(emoji)
        }
        
        return nil
    }
}
