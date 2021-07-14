
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
    @Published var favoritesCellData: [PageCellData] = []
    @Published var archiveCellData: [PageCellData] = []
    @Published var recentCellData: [PageCellData] = []
    
    @Published var newPageData = NewPageData(pageId: "", showingNewPage: false)
    let coordinator: HomeCoordinator = ServiceLocator.shared.homeCoordinator()

    private let dashboardService: DashboardServiceProtocol = ServiceLocator.shared.dashboardService()
    private let blockActionsService: BlockActionsServiceSingleProtocol = ServiceLocator.shared.blockActionsServiceSingle()
    let objectActionsService: ObjectActionsServiceProtocol = ServiceLocator.shared.objectActionsService()
    let searchService = ServiceLocator.shared.searchService()
    
    private var subscriptions = [AnyCancellable]()
    private var newPageSubscription: AnyCancellable?
            
    let document: BaseDocumentProtocol = BaseDocument()
    private lazy var cellDataBuilder = HomeCellDataBuilder(document: document)
    
    init() {
        fetchDashboardData()
    }
    
    func updateSearchTabs() {
        searchService.searchArchivedPages { [weak self] searchResults in
            guard let self = self else { return }
            self.archiveCellData = self.cellDataBuilder.buldCellData(searchResults)
        }
        searchService.searchRecentPages { [weak self] searchResults in
            guard let self = self else { return }
            self.recentCellData = self.cellDataBuilder.buldCellData(searchResults)
        }
    }
    
    private func fetchDashboardData() {        
        dashboardService.openDashboard() { [weak self] serviceSuccess in
            self?.onOpenDashboard(serviceSuccess)
        }
    }
    
    private func onOpenDashboard(_ serviceSuccess: ServiceSuccess) {
        document.updateBlockModelPublisher.receiveOnMain().sink { [weak self] updateResult in
            self?.onDashboardChange(updateResult: updateResult)
        }.store(in: &self.subscriptions)
        
        document.open(serviceSuccess)
    }
    
    private func onDashboardChange(updateResult: BaseDocumentUpdateResult) {
        switch updateResult.updates {
        case .general:
            favoritesCellData = cellDataBuilder.buldFavoritesData(updateResult)
        case .update(let payload):
            payload.updatedIds.forEach { updateCellWithTargetId($0) }
        }
    }
    
    private func updateCellWithTargetId(_ blockId: BlockId) {
        guard let newDetails = document.getDetails(by: blockId)?.currentDetails else {
            assertionFailure("Could not find object with id: \(blockId)")
            return
        }

        favoritesCellData.enumerated()
            .first { $0.element.destinationId == blockId }
            .flatMap { offset, data in
                favoritesCellData[offset] = cellDataBuilder.updatedCellData(newDetails: newDetails, oldData: data)
            }
    }
}

// MARK: - New page
extension HomeViewModel {
    func createNewPage() {
        guard let rootId = document.documentId else { return }
        
        newPageSubscription = dashboardService.createNewPage(contextId: rootId)
            .receiveOnMain()
            .sinkWithDefaultCompletion("Create page") { [weak self] success in
                guard let self = self else {
                    return
                }

                self.document.handle(
                    events: PackOfEvents(contextId: success.contextID, events: success.messages)
                )

                guard let newBlockId = success.newBlockId else {
                    assertionFailure("No new block id in create new page response")
                    return
                }

                self.newPageData = NewPageData(pageId: newBlockId, showingNewPage: true)
        }
    }
}
