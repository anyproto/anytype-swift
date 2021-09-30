
import BlocksModels
import Combine
import Foundation
import ProtobufMessages
import AnytypeCore

final class HomeViewModel: ObservableObject {
    @Published var favoritesCellData: [HomeCellData] = []
    var nonArchivedFavoritesCellData: [HomeCellData] {
        favoritesCellData.filter { $0.isArchived == false }
    }
    
    @Published var archiveCellData: [HomeCellData] = []
    @Published var historyCellData: [HomeCellData] = []
    
    @Published var openedPageData = OpenedPageData.cached
    @Published var showSearch = false
    @Published var snackBarData = SnackBarData(text: "", showSnackBar: false)
    
    let coordinator: HomeCoordinator = ServiceLocator.shared.homeCoordinator()

    private let dashboardService: DashboardServiceProtocol = ServiceLocator.shared.dashboardService()
    private let blockActionsService: BlockActionsServiceSingleProtocol = ServiceLocator.shared.blockActionsServiceSingle()
    let objectActionsService: ObjectActionsServiceProtocol = ServiceLocator.shared.objectActionsService()
    let searchService = ServiceLocator.shared.searchService()
    
    private var subscriptions = [AnyCancellable]()
    private var newPageSubscription: AnyCancellable?
            
    let document: BaseDocumentProtocol = BaseDocument()
    private lazy var cellDataBuilder = HomeCellDataBuilder(document: document)
    
    let bottomSheetCoordinateSpaceName = "BottomSheetCoordinateSpaceName"
    
    init() {
        fetchDashboardData()
    }

    // MARK: - View output

    func viewLoaded() {
        updateArchiveTab()
        updateHistoryTab()
    }

    // MARK: - Private methods

    func updateArchiveTab() {
        searchService.searchArchivedPages { [weak self] searchResults in
            guard let self = self else { return }
            self.archiveCellData = self.cellDataBuilder.buildCellData(searchResults)
        }
    }
    func updateHistoryTab() {
        searchService.searchHistoryPages { [weak self] searchResults in
            guard let self = self else { return }
            self.historyCellData = self.cellDataBuilder.buildCellData(searchResults)
        }
    }
    
    private func fetchDashboardData() {        
        dashboardService.openDashboard() { [weak self] serviceSuccess in
            self?.onOpenDashboard(serviceSuccess)
        }
    }
    
    private func onOpenDashboard(_ serviceSuccess: ResponseEvent) {
        document.updateBlockModelPublisher.receiveOnMain().sink { [weak self] updateResult in
            self?.onDashboardChange(updateResult: updateResult)
        }.store(in: &self.subscriptions)
        
        document.open(serviceSuccess)
    }
    
    private func onDashboardChange(updateResult: BaseDocumentUpdateResult) {
        switch updateResult.updates {
        case .general:
            favoritesCellData = cellDataBuilder.buildFavoritesData(updateResult)
        case .update(let blockIds):
            blockIds.forEach { updateCellWithTargetId($0) }
        case .details(let details):
            updateCellWithTargetId(details.blockId)
        }
    }
    
    private func updateCellWithTargetId(_ blockId: BlockId) {
        guard let newDetails = document.getDetails(id: blockId)?.currentDetails else {
            anytypeAssertionFailure("Could not find object with id: \(blockId)")
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
        let result = dashboardService.createNewPage()
        guard case let .response(response) = result else {
            return
        }

        document.handle(
            events: PackOfEvents(middlewareEvents: response.messages)
        )

        guard !response.newBlockId.isEmpty else {
            anytypeAssertionFailure("No new block id in create new page response")
            return
        }
        
        showPage(pageId: response.newBlockId)
    }
    
    func startSearch() {
        showSearch = true
    }
    
    func showPage(pageId: BlockId) {
        openedPageData.pageId = pageId
        openedPageData.showingNewPage = true
    }
}
