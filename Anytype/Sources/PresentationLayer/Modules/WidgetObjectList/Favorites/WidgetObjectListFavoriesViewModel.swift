import Foundation
import BlocksModels

final class WidgetObjectListFavoriesViewModel: ObservableObject, WidgetObjectListViewModelProtocol {
    
    // MARK: - DI
    
    private let favoriteSubscriptionService: FavoriteSubscriptionServiceProtocol
    private let accountManager: AccountManagerProtocol
    
    // MARK: - State
    
    @Published private(set) var rows: [ListWidgetRow.Model] = []
    private var homeDocument: BaseDocumentProtocol
    
    init(favoriteSubscriptionService: FavoriteSubscriptionServiceProtocol, accountManager: AccountManagerProtocol) {
        self.favoriteSubscriptionService = favoriteSubscriptionService
        self.accountManager = accountManager
        self.homeDocument = BaseDocument(objectId: accountManager.account.info.homeObjectID)
    }
    
    func onAppear() {
        Task { @MainActor [weak self, homeDocument] in
            try? await homeDocument.open()
            self?.favoriteSubscriptionService.startSubscription(homeDocument: homeDocument, objectLimit: nil, update: { details in
                self?.prepareRows(rowDetails: details)
            })
        }
    }
    
    func onDisappear() {
        Task { @MainActor [weak self, homeDocument] in
            try? await homeDocument.close()
            self?.favoriteSubscriptionService.stopSubscription()
        }
    }
    
    // MARK: - Private
    
    func prepareRows(rowDetails: [ObjectDetails]) {
        rows = rowDetails.map { details in
            ListWidgetRow.Model(
                details: details,
                onTap: { [weak self] _ in
                    print("on tap")
//                    self?.output?.onObjectSelected(screenData: $0)
                }
            )
        }
    }
}
