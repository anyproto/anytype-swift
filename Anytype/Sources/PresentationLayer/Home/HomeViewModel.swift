
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
    
    @Published var historyCellData = [HomeCellData]()
    @Published var binCellData = [HomeCellData]()
    @Published var sharedCellData = [HomeCellData]()
    @Published var setsCellData = [HomeCellData]()
    
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
    private let subscriptionService: SubscriptionsServiceProtocol = ServiceLocator.shared.subscriptionService()
    
    let document: BaseDocumentProtocol
    lazy var cellDataBuilder = HomeCellDataBuilder(document: document)
    private lazy var cancellables = [AnyCancellable]()
    
    
    let bottomSheetCoordinateSpaceName = "BottomSheetCoordinateSpaceName"
    
    weak var editorBrowser: EditorBrowser?
    private var quickActionsSubscription: AnyCancellable?
    
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
    }
    
    func onDisappear() {
        subscriptionService.stopAllSubscriptions()
        document.close()
    }
    
    func onTabChange(tab: HomeTabsView.Tab) {
        subscriptionService.stopAllSubscriptions()
        tab.subscriptionId.flatMap { subId in
            subscriptionService.toggleSubscription(id: subId, turnOn: true) { [weak self] id, update in
                self?.onSubscriptionUpdate(id: id, update)
            }
        }
        
        if tab == .favourites {
            updateFavoritesTab()
        }
    }
    
    func onSubscriptionUpdate(id: SubscriptionId, _ update: SubscriptionUpdate) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            withAnimation(update.isInitialData ? nil : .spring()) {
                self.updateCollections(id: id, update)
            }
        }
    }
    
    private func updateCollections(id: SubscriptionId, _ update: SubscriptionUpdate) {
        switch id {
        case .history:
            historyCellData.applySubscriptionUpdate(update, builder: cellDataBuilder)
        case .archive:
            binCellData.applySubscriptionUpdate(update, builder: cellDataBuilder)
        case .shared:
            sharedCellData.applySubscriptionUpdate(update, builder: cellDataBuilder)
        case .sets:
            setsCellData.applySubscriptionUpdate(update, builder: cellDataBuilder)
        default:
            anytypeAssertionFailure("Unsupported subscription: \(id)", domain: .homeView)
        }
    }
    
    func updateFavoritesTab() {
        withAnimation(.spring()) {
            favoritesCellData = cellDataBuilder.buildFavoritesData()
        }
    }
    
    // MARK: - Private methods
    private func setupSubscriptions() {
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
        withAnimation(.spring()) {
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
