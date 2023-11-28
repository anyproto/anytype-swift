import UIKit
import Combine
import Services
import AnytypeCore

final class ChangeTypeAccessoryViewModel {
    typealias TypeItem = HorizontalListItem

    @Published private(set) var isTypesViewVisible: Bool = false
    @Published private(set) var supportedTypes = [TypeItem]()
    var onDoneButtonTap: (() -> Void)?
    var onTypeTap: ((ObjectType) -> Void)?

    private var allSupportedTypes = [TypeItem]()
    private let router: EditorRouterProtocol
    private let handler: BlockActionHandlerProtocol
    private let searchService: SearchServiceProtocol
    private let document: BaseDocumentProtocol
    private lazy var searchItem = TypeItem.searchItem { [weak self] in self?.onSearchTap() }

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

        subscribeOnDocumentChanges()
    }

    func handleDoneButtonTap() {
        onDoneButtonTap?()
    }

    func toggleChangeTypeState() {
        isTypesViewVisible.toggle()
    }

    private func fetchSupportedTypes() {
        Task { @MainActor [weak self] in
            let supportedTypes = try? await self?.searchService
                .searchObjectTypes(
                    text: "",
                    filteringTypeId: nil,
                    shouldIncludeSets: true,
                    shouldIncludeCollections: true,
                    shouldIncludeBookmark: true,
                    spaceId: self?.document.spaceId ?? ""
                ).map { type in
                    TypeItem(from: type, handler: { [weak self] in
                        self?.onTypeTap(type: ObjectType(details: type))
                    })
                }
            
            supportedTypes.map { self?.allSupportedTypes = $0 }
        }
    }

    private func onTypeTap(type: ObjectType) {
        defer { logSelectObjectType(type: type) }
        onTypeTap?(type)
    }
    
    private func logSelectObjectType(type: ObjectType) {
        AnytypeAnalytics.instance().logSelectObjectType(type.analyticsType)
    }

    private func subscribeOnDocumentChanges() {
        document.updatePublisher.sink { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.fetchSupportedTypes()
                self?.updateSupportedTypes()
            }
            
        }.store(in: &cancellables)
    }
    
    private func updateSupportedTypes() {
        let filteredItems = allSupportedTypes.filter {
            $0.id != document.details?.type
        }
        supportedTypes = [searchItem] + filteredItems
        
    }
    
    private func fetchSupportedTypes() async {
        let supportedTypes = try? await searchService
            .searchObjectTypes(
                text: "",
                filteringTypeId: nil,
                shouldIncludeSets: true,
                shouldIncludeCollections: true,
                shouldIncludeBookmark: true,
                spaceId: document.spaceId
            ).map { type in
                TypeItem(from: type, handler: { [weak self] in
                    self?.onTypeTap(type: ObjectType(details: type))
                })
            }
        
        supportedTypes.map { allSupportedTypes = $0 }
    }
    
    private func onSearchTap() {
        router.showTypesForEmptyObject(
            selectedObjectId: document.details?.type,
            onSelect: { [weak self] type in
                self?.onTypeTap(type: type)
            }
        )
    }
}

extension ChangeTypeAccessoryViewModel: TypeListItemProvider {
    var typesPublisher: AnyPublisher<[HorizontalListItem], Never> {
        $supportedTypes.eraseToAnyPublisher()
    }
}
