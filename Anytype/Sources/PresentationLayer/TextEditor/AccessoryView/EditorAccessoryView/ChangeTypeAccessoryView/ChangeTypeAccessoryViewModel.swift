import UIKit
import Combine

final class ChangeTypeAccessoryViewModel {
    typealias TypeItem = HorizonalTypeListViewModel.Item

    @Published private(set) var isTypesViewVisible: Bool = false
    @Published private(set) var supportedTypes = [TypeItem]()

    private var allSupportedTypes = [TypeItem]()
    private let router: EditorRouterProtocol
    private let handler: BlockActionHandlerProtocol
    private let searchService: SearchServiceProtocol
    private let document: BaseDocumentProtocol

    private var cancellables = [AnyCancellable]()

    init(
        router: EditorRouterProtocol,
        handler: BlockActionHandlerProtocol,
        searchService: SearchServiceProtocol,
        document: BaseDocumentProtocol
    ) {
        self.router = router
        self.handler = handler
        self.searchService = searchService
        self.document = document

        fetchSupportedTypes()
        subscribeOnDocumentChanges()
    }

    func handleDoneButtonTap() {
        UIApplication.shared.hideKeyboard()
    }

    func toggleChangeTypeState() {
        isTypesViewVisible.toggle()
    }

    private func fetchSupportedTypes() {
        let supportedTypes = searchService
            .searchObjectTypes(text: "", filteringTypeUrl: nil)?
            .map { object in
                TypeItem(from: object, handler: { [weak handler] in handler?.setObjectTypeUrl(object.id) })
            }

        supportedTypes.map { allSupportedTypes = $0 }
    }

    private func subscribeOnDocumentChanges() {
        document.updatePublisher.sink { [weak self] _ in
            guard let self = self else { return }
            let filteredItems = self.allSupportedTypes.filter {
                $0.id != self.document.details?.type
            }
            self.supportedTypes = filteredItems
        }.store(in: &cancellables)
    }
}

extension ChangeTypeAccessoryViewModel: TypeListItemProvider {
    var typesPublisher: AnyPublisher<[HorizonalTypeListViewModel.Item], Never> {
        $supportedTypes.eraseToAnyPublisher()
    }
}
