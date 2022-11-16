import BlocksModels
import Combine
import Foundation
import ProtobufMessages
import AnytypeCore
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var favoritesCellData: [HomeCellData] = []
    var notDeletedFavoritesCellData: [HomeCellData] {
        favoritesCellData.filter { !$0.isArchived && !$0.isDeleted }
    }
    
    @Published var historyCellData = [HomeCellData]()
    @Published var binCellData = [HomeCellData]()
    @Published var sharedCellData = [HomeCellData]()
    @Published var setsCellData = [HomeCellData]()
    @Published var selectedTab = UserDefaultsConfig.selectedTab
    
    @Published var selectedPageIds: Set<BlockId> = []
    
    @Published private(set) var openedEditorScreenData: EditorScreenData?
    @Published var showingEditorScreenData: Bool = false
    
    @Published var showSearch = false
    @Published var showPagesDeletionAlert = false
    @Published var snackBarData = SnackBarData.empty
    @Published var loadingAlertData = LoadingAlertData.empty
    @Published var loadingDocument = true
    
    @Published private(set) var profileData: HomeProfileData?
    @Published private(set) var settingsViewModel: SettingsViewModel
    
    let objectActionsService: ObjectActionsServiceProtocol = ServiceLocator.shared.objectActionsService()
    
    private let dashboardService: DashboardServiceProtocol = ServiceLocator.shared.dashboardService()
    private let subscriptionService: SubscriptionsServiceProtocol = ServiceLocator.shared.subscriptionService()
    private let tabsSubsciptionDataBuilder: TabsSubscriptionDataBuilderProtocol
    private let profileSubsciptionDataBuilder: ProfileSubscriptionDataBuilderProtocol
    
    let document: BaseDocumentProtocol
    lazy var cellDataBuilder = HomeCellDataBuilder(document: document)
    lazy var favoritesSorter = HomeFavoritesSorter(document: document)
    private lazy var cancellables = [AnyCancellable]()
    
    let bottomSheetCoordinateSpaceName = "BottomSheetCoordinateSpaceName"
    
    weak var editorBrowser: EditorBrowser?
    private var quickActionsSubscription: AnyCancellable?
    
    private let editorBrowserAssembly: EditorBrowserAssembly
    
    init(
        homeBlockId: BlockId,
        editorBrowserAssembly: EditorBrowserAssembly,
        tabsSubsciptionDataBuilder: TabsSubscriptionDataBuilderProtocol,
        profileSubsciptionDataBuilder: ProfileSubscriptionDataBuilderProtocol,
        windowManager: WindowManager
    ) {
        document = BaseDocument(objectId: homeBlockId)
        self.editorBrowserAssembly = editorBrowserAssembly
        self.tabsSubsciptionDataBuilder = tabsSubsciptionDataBuilder
        self.profileSubsciptionDataBuilder = profileSubsciptionDataBuilder
        self.settingsViewModel = SettingsViewModel(
            authService: ServiceLocator.shared.authService(),
            windowManager: windowManager
        )
        setupSubscriptions()
        
        let data = UserDefaultsConfig.screenDataFromLastSession
        showingEditorScreenData = data != nil
        openedEditorScreenData = data
    }

    // MARK: - View output

    func onAppear() {
        Task {
            try await document.open()
            loadingDocument = false
            setupProfileSubscriptions()
            updateCurrentTab()
        }
    }
    
    func onDisappear() {
        Task {
            try await document.close()
            subscriptionService.stopAllSubscriptions()
        }
    }
    
    func onTabChange(tab: HomeTabsView.Tab) {
        guard !loadingDocument else { return }
        
        selectAll(false)
        
        UserDefaultsConfig.selectedTab = tab
        subscriptionService.stopSubscriptions(ids: tabsSubsciptionDataBuilder.allIds())
        let subscriptionData = tabsSubsciptionDataBuilder.build(for: tab)
        
        subscriptionService.startSubscription(data: subscriptionData) { [weak self] id, update in
            withAnimation(update.isInitialData ? nil : .spring()) {
                self?.updateCollections(id: id, update)
            }
        }
        
        AnytypeAnalytics.instance().logHomeTabSelection(tab)
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
        case .pageCount(let count):
            anytypeAssert(count == 1, "Unrecognized count \(count)", domain: .homeView)
            break
        default:
            anytypeAssertionFailure("Usupported update \(update) for profile suscription", domain: .homeView)
        }
    }
    
    private func updateCollections(id: SubscriptionId, _ update: SubscriptionUpdate) {
        switch id {
        case .recentTab:
            historyCellData.applySubscriptionUpdate(update, transform: cellDataBuilder.buildCellData)
        case .archiveTab:
            binCellData.applySubscriptionUpdate(update, transform: cellDataBuilder.buildCellData)
        case .sharedTab:
            sharedCellData.applySubscriptionUpdate(update, transform: cellDataBuilder.buildCellData)
        case .setsTab:
            setsCellData.applySubscriptionUpdate(update, transform: cellDataBuilder.buildCellData)
        case .favoritesTab:
            favoritesCellData.applySubscriptionUpdate(update, transform: cellDataBuilder.buildCellData)
            favoritesCellData = favoritesSorter.sort(data: favoritesCellData)
        default:
            anytypeAssertionFailure("Unsupported subscription: \(id)", domain: .homeView)
        }
    }
    
    // MARK: - Private methods
    private func setupSubscriptions() {
        
        $selectedTab.sink { [weak self] in
            self?.onTabChange(tab: $0)
        }.store(in: &cancellables)
        
        // visual delay on application launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.quickActionsSubscription = QuickActionsStorage.shared.$action.sink { action in
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
    
    private func updateCurrentTab() {
        onTabChange(tab: selectedTab)
    }
    
    private func setupProfileSubscriptions() {
        subscriptionService.startSubscription(
            data: profileSubsciptionDataBuilder.profile(id: AccountManager.shared.account.info.profileObjectID)
        ) { [weak self] id, update in
            withAnimation {
                self?.onProfileUpdate(update: update)
            }
        }
    }
}

// MARK: - New page

extension HomeViewModel {
    
    func startSearch() {
        showSearch = true
    }
    
    func createAndShowNewPage() {
        guard let id = dashboardService.createNewPage() else { return }
        
        AnytypeAnalytics.instance().logCreateObject(
            objectType: ObjectTypeProvider.shared.defaultObjectType.url,
            route: .home
        )
        
        showPage(id: id, viewType: .page)
    }
    
    func showProfile() {
        guard let id = profileData?.blockId else { return }
        showPage(id: id, viewType: .page)
    }
    
    func showPage(id: BlockId, viewType: EditorViewType) {
        let data = EditorScreenData(pageId: id, type: viewType)
        
        if showingEditorScreenData {
            editorBrowser?.showPage(data: data)
        } else {
            openedEditorScreenData = data
            showingEditorScreenData = true
        }
    }
    
    func createBrowser(data: EditorScreenData) -> some View {
        editorBrowserAssembly.editor(data: data, model: self)
            .eraseToAnyView()
            .edgesIgnoringSafeArea(.all)
    }
    
}
