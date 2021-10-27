import UIKit
import Combine

final class ChangeTypeAccessoryViewModel {
    typealias TypeItem = HorizonalTypeListViewModel.Item

    @Published private(set) var isTypesViewVisible: Bool = false
    @Published private(set) var supportedTypes = [TypeItem]()

    private let router: EditorRouterProtocol
    private let handler: EditorActionHandlerProtocol
    private let searchService: SearchServiceProtocol
    private let document: BaseDocumentProtocol

    init(
        router: EditorRouterProtocol,
        handler: EditorActionHandlerProtocol,
        searchService: SearchServiceProtocol,
        document: BaseDocumentProtocol
    ) {
        self.router = router
        self.handler = handler
        self.searchService = searchService
        self.document = document

        fetchSupportedTypes()
    }

    func handleDoneButtonTap() {
        UIApplication.shared.hideKeyboard()
    }

    func toogleChangeTypeState() {
        isTypesViewVisible.toggle()
    }

    private func fetchSupportedTypes() {
        let supportedTypes = searchService
            .searchObjectTypes(text: "", filteringTypeUrl: nil)?
            .map { object in
                TypeItem(from: object, handler: { [weak handler] in handler?.setObjectTypeUrl(object.id) })
            }

        supportedTypes.map { self.supportedTypes = $0 }
    }
}

extension ChangeTypeAccessoryViewModel: TypeListItemProvider {
    var typesPublisher: Published<[HorizonalTypeListViewModel.Item]>.Publisher { $supportedTypes }
}
