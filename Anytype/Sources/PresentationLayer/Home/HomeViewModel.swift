
import BlocksModels
import Combine
import Foundation
import ProtobufMessages
import AnytypeCore
import SwiftUI
import Amplitude

final class HomeViewModel: ObservableObject {
    @Published var favoritesCellData: [HomeCellData] = []
    var notDeletedFavoritesCellData: [HomeCellData] {
        favoritesCellData.filter { !$0.isArchived && !$0.isDeleted }
    }
    
    var historyCellData: [HomeCellData] {
        cellDataBuilder.buildCellData(SubscriptionsStorage.shared.history)
    }
    var binCellData: [HomeCellData] {
        cellDataBuilder.buildCellData(SubscriptionsStorage.shared.archive)
    }
    var sharedCellData: [HomeCellData] {
        cellDataBuilder.buildCellData(SubscriptionsStorage.shared.shared)
    }
    var setsCellData: [HomeCellData] {
        cellDataBuilder.buildCellData(SubscriptionsStorage.shared.sets)
    }
    
    @Published var selectedPageIds: Set<BlockId> = []
    @Published var openedPageData = OpenedPageData.cached
    @Published var showSearch = false
    @Published var showDeletionAlert = false
    @Published var snackBarData = SnackBarData.empty
    @Published var loadingAlertData = LoadingAlertData.empty
    
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
    private var subscriptionStorageSubscription: AnyCancellable?
    
    init() {
        let homeBlockId = configurationService.configuration().homeBlockID
        document = BaseDocument(objectId: homeBlockId)
        document.updatePublisher.sink { [weak self] in
            self?.onDashboardChange(updateResult: $0)
        }.store(in: &cancellables)
        setupSubscriptions()
    }

    // MARK: - View output

    func onAppear() {
        document.open()
        animationsEnabled = true
    }
    
    func onDisappear() {
        document.close()
        SubscriptionsStorage.shared.toggleSubscriptions(ids: HomeTabsView.Tab.allCases.compactMap(\.subscriptionId), false)
    }
    
    func onTabChange(tab: HomeTabsView.Tab) {
        var subscriptions = HomeTabsView.Tab.allCases.compactMap(\.subscriptionId)
        tab.subscriptionId.flatMap { subId in
            subscriptions.removeAllOccurrences(of: subId)
            SubscriptionsStorage.shared.toggleSubscription(id: subId, true)
        }
        SubscriptionsStorage.shared.toggleSubscriptions(ids: subscriptions, false)
        
        Amplitude.instance().logEvent(tab.amplitudeEventName)
        
        if tab == .favourites {
            updateFavoritesTab()
        }
    }
    
    func updateFavoritesTab() {
        withAnimation(animationsEnabled ? .spring() : nil) {
            favoritesCellData = cellDataBuilder.buildFavoritesData()
        }
    }
    
    // MARK: - Private methods
    private func setupSubscriptions() {
        subscriptionStorageSubscription = SubscriptionsStorage.shared.objectWillChange
            .receiveOnMain()
            .sink { [weak self] in
                guard let self = self else { return }
                withAnimation(self.animationsEnabled ? .spring() : nil) {
                    self.objectWillChange.send()
                }
            }
        
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
                updateFavoritesTab()
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
        guard let newDetails = ObjectDetailsStorage.shared.get(id: blockId) else {
            anytypeAssertionFailure("Could not find object with id: \(blockId)", domain: .homeView)
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
        
        showPage(pageId: blockId, viewType: .page)
    }
    
    func showPage(pageId: BlockId, viewType: EditorViewType) {
        let data = EditorScreenData(pageId: pageId, type: viewType)
        
        if openedPageData.showing {
            editorBrowser?.showPage(data: data)
        } else {
            animationsEnabled = false // https://app.clickup.com/t/1jz5kg4
            openedPageData.data = data
            openedPageData.showing = true
        }
    }
    
    func createBrowser() -> some View {
        EditorBrowserAssembly().editor(data: openedPageData.data, model: self)
            .eraseToAnyView()
            .edgesIgnoringSafeArea(.all)
    }
    
    private func createNewPage() -> BlockId? {
        guard let newBlockId = dashboardService.createNewPage() else { return nil }

        if newBlockId.isEmpty {
            anytypeAssertionFailure("No new block id in create new page response", domain: .homeView)
            return nil
        }
        
        return newBlockId
    }
}
