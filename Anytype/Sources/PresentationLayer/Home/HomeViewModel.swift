
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
    
    @Published private(set) var profileData = HomeProfileData.empty
    
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
        subscriptionService.startSubscription(
            data: .profile(id: MiddlewareConfigurationService.shared.configuration().profileBlockId)
        ) { [weak self] id, update in
            withAnimation {
                self?.onProfileUpdate(update: update)
            }
        }
    }
    
    func onDisappear() {
        subscriptionService.stopAllSubscriptions()
        document.close()
    }
    
    func onTabChange(tab: HomeTabsView.Tab) {
        subscriptionService.stopSubscriptions(ids: [.sharedTab, .setsTab, .archiveTab, .historyTab])
        tab.subscriptionId.flatMap { subId in
            subscriptionService.startSubscription(data: subId) { [weak self] id, update in
                withAnimation(update.isInitialData ? nil : .spring()) {
                    self?.updateCollections(id: id, update)
                }
            }
        }
        
        if tab == .favourites {
            updateFavoritesTab()
        }
    }
    
    private func onProfileUpdate(update: SubscriptionUpdate) {
        switch update {
        case .initialData(let array):
            guard let details = array.first else {
                anytypeAssertionFailure("Emppty data for profile subscription", domain: .homeView)
                return
            }
            profileData = HomeProfileData(details: details)
        case .update(let details):
            profileData = HomeProfileData(details: details)
        default:
            anytypeAssertionFailure("Usupported update \(update) for profile suscription", domain: .homeView)
        }
    }
    
    private func updateCollections(id: SubscriptionId, _ update: SubscriptionUpdate) {
        switch id {
        case .historyTab:
            historyCellData.applySubscriptionUpdate(update, transform: cellDataBuilder.buildCellData)
        case .archiveTab:
            binCellData.applySubscriptionUpdate(update, transform: cellDataBuilder.buildCellData)
        case .sharedTab:
            sharedCellData.applySubscriptionUpdate(update, transform: cellDataBuilder.buildCellData)
        case .setsTab:
            setsCellData.applySubscriptionUpdate(update, transform: cellDataBuilder.buildCellData)
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
