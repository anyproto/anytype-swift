
import BlocksModels
import Combine
import Foundation
import ProtobufMessages
import AnytypeCore
import SwiftUI

final class HomeViewModel: ObservableObject {
    @Published var favoritesCellData: [HomeCellData] = []
    var notDeletedFavoritesCellData: [HomeCellData] {
        favoritesCellData.filter { !$0.isArchived && !$0.isDeleted }
    }
    
    @Published var historyCellData: [HomeCellData] = []
    @Published var binCellData: [HomeCellData] = []
    @Published var sharedCellData: [HomeCellData] = []
    @Published var setsCellData: [HomeCellData] = []
    
    @Published var openedPageData = OpenedPageData.cached
    @Published var showSearch = false
    @Published var showDeletionAlert = false
    @Published var snackBarData = SnackBarData(text: "", showSnackBar: false)
    
    let objectActionsService: ObjectActionsServiceProtocol = ServiceLocator.shared.objectActionsService()
    let searchService = ServiceLocator.shared.searchService()
    private let configurationService = MiddlewareConfigurationService.shared
    private let dashboardService: DashboardServiceProtocol = ServiceLocator.shared.dashboardService()
    
    let document: BaseDocumentProtocol
    private lazy var cellDataBuilder = HomeCellDataBuilder(document: document)
    private lazy var cancellables = [AnyCancellable]()
    
    
    let bottomSheetCoordinateSpaceName = "BottomSheetCoordinateSpaceName"
    private var animationsEnabled = true
    
    weak var editorBrowser: EditorBrowser?
    private var quickActionsSubscription: AnyCancellable?
    
    init() {
        let homeBlockId = configurationService.configuration().homeBlockID
        document = BaseDocument(objectId: homeBlockId)
        document.updatePublisher.sink { [weak self] in
            self?.onDashboardChange(updateResult: $0)
        }.store(in: &cancellables)
        document.open()
        setupQuickActionsSubscription()
    }

    // MARK: - View output

    func viewLoaded() {
        reloadItems()
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
    func updateSharedTab() {
        guard let searchResults = searchService.searchSharedPages() else { return }
        withAnimation(animationsEnabled ? .spring() : nil) {
            sharedCellData = cellDataBuilder.buildCellData(searchResults)
        }
    }
    func updateFavoritesTab() {
        withAnimation(animationsEnabled ? .spring() : nil) {
            favoritesCellData = cellDataBuilder.buildFavoritesData()
        }
    }
    func updateSetsTab() {
        guard let searchResults = searchService.searchSets() else { return }
        withAnimation(animationsEnabled ? .spring() : nil) {
            setsCellData = cellDataBuilder.buildCellData(searchResults)
        }
    }
    
    // MARK: - Private methods
    private func setupQuickActionsSubscription() {
        // visual delay on application launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.quickActionsSubscription = QuickActionsStorage.shared.$action.sink { [weak self] action in
                switch action {
                case .newNote:
                    self?.createAndShowNewPage()
                    QuickActionsStorage.shared.action = nil
                case .none:
                    break
                }
            }
        }
    }
    
    private func onDashboardChange(updateResult: EventsListenerUpdate) {
        withAnimation(animationsEnabled ? .spring() : nil) {
            switch updateResult {
            case .general:
                reloadItems()
            case .blocks(let blockIds):
                blockIds.forEach { updateFavoritesCellWithTargetId($0) }
            case .details(let detailId):
                updateFavoritesCellWithTargetId(detailId)
            case .syncStatus:
                break
            }
        }
    }

    private func reloadItems() {
        updateBinTab()
        updateHistoryTab()
        updateFavoritesTab()
        updateSharedTab()
        updateSetsTab()
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
    func startSearch() {
        showSearch = true
    }
    
    func createAndShowNewPage() {
        guard let blockId = createNewPage() else { return }
        
        showPage(pageId: blockId)
    }
    
    func showPage(pageId: BlockId) {
        if openedPageData.showingNewPage {
            editorBrowser?.showPage(pageId: pageId)
        } else {
            animationsEnabled = false // https://app.clickup.com/t/1jz5kg4
            openedPageData.pageId = pageId
            openedPageData.showingNewPage = true
        }
    }
    
    func createBrowser() -> some View {
        EditorBrowserAssembly().editor(blockId: openedPageData.pageId, model: self)
            .eraseToAnyView()
            .edgesIgnoringSafeArea(.all)
    }
    
    private func createNewPage() -> BlockId? {
        guard let newBlockId = dashboardService.createNewPage() else { return nil }

        if newBlockId.isEmpty {
            anytypeAssertionFailure("No new block id in create new page response")
            return nil
        }
        
        return newBlockId
    }
}
