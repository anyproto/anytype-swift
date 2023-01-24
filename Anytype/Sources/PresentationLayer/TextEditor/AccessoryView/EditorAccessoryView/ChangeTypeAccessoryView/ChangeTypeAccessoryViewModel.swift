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
    private lazy var searchItem = TypeItem.searchItem { [weak self] in self?.onSearchTap() }

    private var cancellables = [AnyCancellable]()

    init(
        router: EditorRouterProtocol,
        handler: BlockActionHandlerProtocol,
        searchService: SearchServiceProtocol,
        objectService: ObjectActionsServiceProtocol,
        document: BaseDocumentProtocol
    ) {
        self.router = router
        self.handler = handler
        self.searchService = searchService
        self.objectService = objectService
        self.document = document

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
            .searchObjectTypes(text: "", filteringTypeId: nil, shouldIncludeSets: true, shouldIncludeBookmark: false)?
            .map { type in
                TypeItem(from: type, handler: { [weak self] in
                    self?.onTypeTap(typeId: type.id)
                })
            }

        supportedTypes.map { allSupportedTypes = $0 }
    }

    private func onTypeTap(typeId: String) {
        if typeId == ObjectTypeId.BundledTypeId.set.rawValue {
            let setObjectID = handler.setObjectSetType()

            router.replaceCurrentPage(with: .init(pageId: setObjectID, type: .set()))
            return
        }

        handler.setObjectTypeId(typeId)
        applyDefaultTemplateIfNeeded(typeId: typeId)
    }
    
    private func applyDefaultTemplateIfNeeded(typeId: String) {
        let availableTemplates = searchService.searchTemplates(for: .dynamic(typeId))
        
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
    
    private func onSearchTap() {
        router.showTypesForEmptyObject(
            selectedObjectId: document.details?.type,
            onSelect: { [weak self] typeId in
                self?.onTypeTap(typeId: typeId)
            }
        )
    }
}

extension ChangeTypeAccessoryViewModel: TypeListItemProvider {
    var typesPublisher: AnyPublisher<[HorizontalListItem], Never> {
        $supportedTypes.eraseToAnyPublisher()
    }
}
