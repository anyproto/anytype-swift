import UIKit
import Combine
import Services
import AnytypeCore

final class ChangeTypeAccessoryViewModel {
    typealias TypeItem = HorizontalListItem

    @Published private(set) var isTypesViewVisible: Bool = false
    @Published private(set) var supportedTypes = [TypeItem]()
    var onDoneButtonTap: (() -> Void)?
    var onTypeSelected: ((TypeSelectionResult) -> Void)?

    private let router: EditorRouterProtocol
    private let handler: BlockActionHandlerProtocol
    private let typesService: TypesServiceProtocol
    private let document: BaseDocumentProtocol

    private var cancellables = [AnyCancellable]()

    init(
        router: EditorRouterProtocol,
        handler: BlockActionHandlerProtocol,
        typesService: TypesServiceProtocol,
        document: BaseDocumentProtocol
    ) {
        self.router = router
        self.handler = handler
        self.typesService = typesService
        self.document = document

        subscribeOnDocumentChanges()
    }

    func handleDoneButtonTap() {
        onDoneButtonTap?()
    }

    func toggleChangeTypeState() {
        isTypesViewVisible.toggle()
    }
    
    func onSearchTap() {
        router.showTypeSearchForObjectCreation(
            selectedObjectId: document.details?.type,
            onSelect: { [weak self] result in
                self?.onTypeSelected(result: result)
            }
        )
    }

    private func onTypeSelected(result: TypeSelectionResult) {
        onTypeSelected?(result)
    }

    private func subscribeOnDocumentChanges() {
        document.detailsPublisher.sink { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let supportedTypes = await fetchSupportedTypes() {
                    self.supportedTypes = supportedTypes
                }
            }
        }.store(in: &cancellables)
    }
    
    private func fetchSupportedTypes() async -> [TypeItem]? {
        let supportedTypes = try? await typesService
            .searchObjectTypes(
                text: "",
                includePins: true,
                includeLists: true,
                includeBookmark: true, 
                includeFiles: false,
                incudeNotForCreation: false,
                spaceId: document.spaceId
            ).map { type in
                TypeItem(from: type, handler: { [weak self] in
                    self?.onTypeSelected(result: .objectType(type: ObjectType(details: type)))
                })
            }
        return supportedTypes
    }
}

extension ChangeTypeAccessoryViewModel: TypeListItemProvider {
    var typesPublisher: AnyPublisher<[HorizontalListItem], Never> {
        $supportedTypes.eraseToAnyPublisher()
    }
}
