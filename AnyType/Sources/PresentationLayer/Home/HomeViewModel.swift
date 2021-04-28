import Combine
import Foundation
import BlocksModels


final class HomeViewModel: ObservableObject {
    @Published var cellData: [PageCellData] = []
    let coordinator: OldHomeCoordinator = ServiceLocator.shared.homeCoordinator()

    private let dashboardService: DashboardServiceProtocol = ServiceLocator.shared.dashboardService()
    private let blockActionsService: BlockActionsServiceSingleProtocol = ServiceLocator.shared.blockActionsServiceSingle()
    
    private var subscriptions: Set<AnyCancellable> = []
            
    private let documentViewModel: DocumentViewModelProtocol = DocumentViewModel()
    
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
                destinationId: destinationId(pageLinkViewModel),
                iconData: iconData(details),
                title: details.title?.value ?? "",
                type: "Page"
            )
        }
    }
    
    private func destinationId(_ pageLinkViewModel: BlockPageLinkViewModel) -> String {
        let targetBlockId: String
        if case let .link(link) = pageLinkViewModel.getBlock().blockModel.information.content {
            targetBlockId = link.targetBlockID
        }
        else {
            assertionFailure("No target id for \(pageLinkViewModel)")
            targetBlockId = ""
        }
        return targetBlockId
    }
    
    private func iconData(_ details: DetailsInformationProvider) -> PageCellIconData? {
        if let imageId = details.iconImage?.value, !imageId.isEmpty {
            return .imageId(imageId)
        } else if let emoji = details.iconEmoji?.value, !emoji.isEmpty {
            return .emoji(emoji)
        }
        
        return nil
    }
}
