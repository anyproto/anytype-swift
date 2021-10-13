
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
    
    private let configurationService = MiddlewareConfigurationService.shared
    private let dashboardService: DashboardServiceProtocol = ServiceLocator.shared.dashboardService()
    let objectActionsService: ObjectActionsServiceProtocol = ServiceLocator.shared.objectActionsService()
    let searchService = ServiceLocator.shared.searchService()
    
    let document: BaseDocumentProtocol
    private lazy var cellDataBuilder = HomeCellDataBuilder(document: document)
    
    let bottomSheetCoordinateSpaceName = "BottomSheetCoordinateSpaceName"
    
    init() {
        let homeBlockId = configurationService.configuration().homeBlockID
        document = BaseDocument(objectId: homeBlockId)
        document.onUpdateReceive = { [weak self] updateResult in
            self?.onDashboardChange(updateResult: updateResult)
        }
        document.open()
    }

    // MARK: - View output

    func viewLoaded() {
        updateArchiveTab()
        updateHistoryTab()
    }

    // MARK: - Private methods

    func updateArchiveTab() {
        guard let searchResults = searchService.searchArchivedPages() else { return }
        archiveCellData = cellDataBuilder.buildCellData(searchResults)
    }
    func updateHistoryTab() {
        guard let searchResults = searchService.searchHistoryPages() else { return }
        historyCellData = cellDataBuilder.buildCellData(searchResults)
    }
    
    private func onDashboardChange(updateResult: BaseDocumentUpdateResult) {
        switch updateResult.updates {
        case .general:
            favoritesCellData = cellDataBuilder.buildFavoritesData(updateResult)
        case .update(let blockIds):
            blockIds.forEach { updateCellWithTargetId($0) }
        case .details(let details):
            updateCellWithTargetId(details.id)
        case .syncStatus(let status):
            anytypeAssertionFailure("Not supported event sync status: \(status)")
        }
    }
    
    private func updateCellWithTargetId(_ blockId: BlockId) {
        guard let newDetails = document.getDetails(id: blockId) else {
            anytypeAssertionFailure("Could not find object with id: \(blockId)")
            return
        }

        favoritesCellData.enumerated()
            .first { $0.element.destinationId == blockId }
            .flatMap { offset, data in
                favoritesCellData[offset] = cellDataBuilder.updatedCellData(
                    newDetails: newDetails,
                    oldData: data
                )
            }
    }
}

// MARK: - New page
extension HomeViewModel {
    func createNewPage() {
        guard let response = dashboardService.createNewPage() else { return }
        
        EventsBunch(
            objectId: document.objectId,
            middlewareEvents: response.messages
        ).send()

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
