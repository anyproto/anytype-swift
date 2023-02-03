import Foundation
import BlocksModels
import Combine

@MainActor
final class FavoriteWidgetViewModel: ListWidgetViewModelProtocol, WidgetContainerContentViewModelProtocol, ObservableObject {
    
    private enum Constants {
        static let maxItems = 3
    }
    
    // MARK: - DI
    
    private let widgetBlockId: BlockId
    private let widgetObject: HomeWidgetsObjectProtocol
    private let accountManager: AccountManagerProtocol
    private let favoriteSubscriptionService: FavoriteSubscriptionServiceProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State
    
    private var document: BaseDocumentProtocol
    private var rowDetails: [ObjectDetails] = []
    
    // MARK: - WidgetContainerContentViewModelProtocol
    
    let name: String = Loc.favorites
    let menuItems: [WidgetMenuItem] = []
    
    // MARK: - ListWidgetViewModelProtocol
    
    @Published private(set) var rows: [ListWidgetRow.Model] = []
    let minimimRowsCount = Constants.maxItems
    
    init(
        widgetBlockId: BlockId,
        widgetObject: HomeWidgetsObjectProtocol,
        accountManager: AccountManagerProtocol,
        favoriteSubscriptionService: FavoriteSubscriptionServiceProtocol,
        documentService: DocumentServiceProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.accountManager = accountManager
        self.favoriteSubscriptionService = favoriteSubscriptionService
        self.output = output
        self.document = documentService.document(objectId: accountManager.account.info.homeObjectID)
    }
    
    // MARK: - ListWidgetViewModelProtocol
    
    func onAppear() {
        setupAllSubscriptions()
    }

    func onDisappear() {
        favoriteSubscriptionService.stopSubscription()
    }
    
    func onHeaderTap() {
        output?.onObjectSelected(screenData: EditorScreenData(pageId: "", type: .favorites))
    }
    
    // MARK: - Private
    
    private func setupAllSubscriptions() {
        favoriteSubscriptionService.startSubscription(
            homeDocument: document,
            objectLimit: Constants.maxItems,
            update: { [weak self] details in
                self?.rowDetails = details
                self?.updateViewState()
            }
        )
    }
    
    private func updateViewState() {
        rows = rowDetails.map { details in
            ListWidgetRow.Model(
                details: details,
                onTap: { [weak self] in
                    self?.output?.onObjectSelected(screenData: $0)
                }
            )
        }
    }
}
