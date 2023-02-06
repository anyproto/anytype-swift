import Foundation
import BlocksModels

final class WidgetObjectListFavoriesViewModel: ObservableObject, WidgetObjectListViewModelProtocol {
    
    // MARK: - DI
    
    private let favoriteSubscriptionService: FavoriteSubscriptionServiceProtocol
    
    // MARK: - State
    
    var title = Loc.favorites
    var editorViewType: EditorViewType = .favorites
    @Published private(set) var rows: [ListRowConfiguration] = []
    private var rowDetails: [ObjectDetails] = []
    private var searchText: String?
    private var homeDocument: BaseDocumentProtocol
    
    private weak var output: WidgetObjectListCommonModuleOutput?
    
    init(
        favoriteSubscriptionService: FavoriteSubscriptionServiceProtocol,
        accountManager: AccountManagerProtocol,
        documentService: DocumentServiceProtocol,
        output: WidgetObjectListCommonModuleOutput?
    ) {
        self.favoriteSubscriptionService = favoriteSubscriptionService
        self.homeDocument = documentService.document(objectId: accountManager.account.info.homeObjectID)
        self.output = output
    }
    
    func onAppear() {
        favoriteSubscriptionService.startSubscription(homeDocument: homeDocument, objectLimit: nil, update: { [weak self] details in
            self?.rowDetails = details
            self?.updateRows()
        })
    }
    
    func onDisappear() {
        favoriteSubscriptionService.stopSubscription()
    }
    
    func didAskToSearch(text: String) {
        searchText = text
        updateRows()
    }
    
    // MARK: - Private
    
    private func updateRows() {
        
        var filteredDetails: [ObjectDetails]
        if let searchText = searchText?.lowercased(), searchText.isNotEmpty {
            filteredDetails = rowDetails.filter { $0.title.range(of: searchText, options: .caseInsensitive) != nil }
        } else {
            filteredDetails = rowDetails
        }
        
        rows = filteredDetails.map { details in
            ListRowConfiguration.widgetSearchConfiguration(
                objectDetails: details,
                onTap: { [weak self] screenData in
                    self?.output?.onObjectSelected(screenData: screenData)
                }
            )
        }
    }
}
