import UIKit
import Combine
import BlocksModels

final class ChangeTypeAccessoryViewModel {
    typealias TypeItem = HorizontalListItem

    @Published private(set) var isTypesViewVisible: Bool = true
    @Published private(set) var supportedTypes = [TypeItem]()
    var onDoneButtonTap: (() -> Void)?

    private var allSupportedTypes = [TypeItem]()
    private let router: EditorRouterProtocol
    private let handler: BlockActionHandlerProtocol
    private let searchService: SearchServiceProtocol
    private let objectService: ObjectActionsServiceProtocol
    private let document: BaseDocumentProtocol
    private let searchHandler: () -> Void
    private lazy var searchItem = TypeItem.searchItem { [weak self] in self?.searchHandler() }

    private var cancellables = [AnyCancellable]()

    init(
        router: EditorRouterProtocol,
        handler: BlockActionHandlerProtocol,
        searchService: SearchServiceProtocol,
        objectService: ObjectActionsServiceProtocol,
        document: BaseDocumentProtocol,
        searchHandler: @escaping () -> Void
    ) {
        self.router = router
        self.handler = handler
        self.searchService = searchService
        self.objectService = objectService
        self.document = document
        self.searchHandler = searchHandler

        fetchSupportedTypes()
        subscribeOnDocumentChanges()
    }

    func handleDoneButtonTap() {
        onDoneButtonTap?()
    }

    func toggleChangeTypeState() {
        isTypesViewVisible.toggle()
    }

    private func fetchSupportedTypes() {
        let supportedTypes = searchService
            .searchObjectTypes(text: "", filteringTypeUrl: nil, shouldIncludeSets: true)?
            .map { object in
                TypeItem(from: object, handler: { [weak self] in
                    self?.onObjectTap(object: object)
                })
            }

        supportedTypes.map { allSupportedTypes = $0 }
    }

    private func onObjectTap(object: ObjectDetails) {
        if object.id == ObjectTypeUrl.BundledTypeUrl.set.rawValue {
            let setObjectID = handler.setObjectSetType()

            router.replaceCurrentPage(with: .init(pageId: setObjectID, type: .set))
            return
        }

        handler.setObjectTypeUrl(object.id)
        applyDefaultTemplateIfNeeded(typeDetails: object)
    }
    
    private func applyDefaultTemplateIfNeeded(typeDetails: ObjectDetails) {
        let availableTemplates = searchService.searchTemplates(for: .dynamic(typeDetails.id))
        
        guard availableTemplates?.count == 1,
                let firstTemplate = availableTemplates?.first
            else { return }
        
        objectService.applyTemplate(objectId: document.objectId, templateId: firstTemplate.id)
    }

    private func subscribeOnDocumentChanges() {
        document.updatePublisher.sink { [weak self] _ in
            guard let self = self else { return }
            let filteredItems = self.allSupportedTypes.filter {
                $0.id != self.document.details?.type
            }
            self.supportedTypes = [self.searchItem] + filteredItems
        }.store(in: &cancellables)
    }
}

extension ChangeTypeAccessoryViewModel: TypeListItemProvider {
    var typesPublisher: AnyPublisher<[HorizontalListItem], Never> {
        $supportedTypes.eraseToAnyPublisher()
    }
}
