import Foundation
import Services
import Combine

@MainActor
final class WidgetObjectListFavoritesViewModel: WidgetObjectListInternalViewModelProtocol {
    
    private enum Constants {
        static let sectionId = "Favorite"
    }
    
    // MARK: - DI
    
    @Injected(\.favoriteSubscriptionService)
    private var favoriteSubscriptionService: FavoriteSubscriptionServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionService: ObjectActionsServiceProtocol
    @Injected(\.documentService)
    private var documentService: OpenedDocumentsProviderProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    
    // MARK: - State
    
    let title = Loc.favorites
    let editorScreenData: EditorScreenData = .favorites
    var rowDetailsPublisher: AnyPublisher<[WidgetObjectListDetailsData], Never> { $rowDetails.eraseToAnyPublisher() }
    let editMode: WidgetObjectListEditMode = .normal(allowDnd: true)
    
    @Published private var rowDetails: [WidgetObjectListDetailsData] = []
    lazy private var homeDocument: BaseDocumentProtocol =
        documentService.document(objectId: activeWorkspaceStorage.workspaceInfo.homeObjectID)
    
    
    private var details: [FavoriteBlockDetails] = [] {
        didSet { rowDetails = [WidgetObjectListDetailsData(id: Constants.sectionId, details: details.map(\.details))] }
    }
    
    // MARK: - WidgetObjectListInternalViewModelProtocol
    
    func onAppear() {
        favoriteSubscriptionService.startSubscription(homeDocument: homeDocument, objectLimit: nil, update: { [weak self] details in
            self?.details = details
        })
    }
    
    func onDisappear() {
        favoriteSubscriptionService.stopSubscription()
    }
    
    func onMove(from: IndexSet, to: Int) {
        guard let fromIndex = from.first else { return }
        
        let toIndex = to > fromIndex ? to - 1 : to

        guard fromIndex != toIndex, fromIndex < details.count, toIndex < details.count else { return }
        let firstDetails = details[fromIndex]
        let toDetails = details[toIndex]
                
        Task {
            try? await objectActionService.move(
                dashboadId: homeDocument.objectId,
                blockId: firstDetails.blockId,
                dropPositionblockId: toDetails.blockId,
                position: to > fromIndex ? .bottom : .top
            )
        }
    }
    
    func subtitle(for details: ObjectDetails) -> String? {
        return details.subtitle
    }
}
