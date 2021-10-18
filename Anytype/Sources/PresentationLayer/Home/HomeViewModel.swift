
import BlocksModels
import Combine
import Foundation
import ProtobufMessages
import AnytypeCore
import SwiftUI

final class HomeViewModel: ObservableObject {
    @Published var favoritesCellData: [HomeCellData] = []
    var nonArchivedFavoritesCellData: [HomeCellData] {
        favoritesCellData.filter { $0.isArchived == false }
    }
    
    @Published var historyCellData: [HomeCellData] = []
    
    @Published var binCellData: [HomeCellData] = []
    var isSelectionMode: Bool { binCellData.filter { $0.selected }.isNotEmpty }
    var isAllSelected: Bool { binCellData.first { !$0.selected }.isNil }
    var numberOfSelectedPages: Int { binCellData.filter { $0.selected }.count }
    
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
    private var animationsEnabled = true
    
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
        updateBinTab()
        updateHistoryTab()
        animationsEnabled = true
    }

    func updateBinTab() {
        guard let searchResults = searchService.searchArchivedPages() else { return }
        withAnimation(animationsEnabled ? .spring() : nil) {
            binCellData = cellDataBuilder.buildCellData(searchResults)
        }
    }
    func updateHistoryTab() {
        guard let searchResults = searchService.searchHistoryPages() else { return }
        withAnimation(animationsEnabled ? .spring() : nil) {
            historyCellData = cellDataBuilder.buildCellData(searchResults)
        }
    }
    
    func selectAll(_ select: Bool) {
        binCellData.indices.forEach { index in
            binCellData[index].selected = select
        }
    }
    
    func select(data: HomeCellData) {
        guard let index = binCellData.firstIndex(where: { $0.id == data.id }) else {
            anytypeAssertionFailure("No page in bin for data: \(data)")
            return
        }
        
        binCellData[index].selected.toggle()
    }
    
    // MARK: - Private methods
    private func onDashboardChange(updateResult: EventsListenerUpdate) {
        withAnimation(animationsEnabled ? .spring() : nil) {
            switch updateResult {
            case .general:
                favoritesCellData = cellDataBuilder.buildFavoritesData(updateResult)
            case .blocks(let blockIds):
                blockIds.forEach { updateFavoritesCellWithTargetId($0) }
            case .details(let detailId):
                updateFavoritesCellWithTargetId(detailId)
            case .syncStatus:
                break
            }
        }
    }
    
    private func updateFavoritesCellWithTargetId(_ blockId: BlockId) {
        guard let newDetails = document.detailsStorage.get(id: blockId) else {
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
        animationsEnabled = false // https://app.clickup.com/t/1jz5kg4
        openedPageData.pageId = pageId
        openedPageData.showingNewPage = true
    }
}
