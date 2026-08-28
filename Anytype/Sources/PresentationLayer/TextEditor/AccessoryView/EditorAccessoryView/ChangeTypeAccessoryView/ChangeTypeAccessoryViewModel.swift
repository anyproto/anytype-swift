import UIKit
import Combine
import Services
import AnytypeCore

@MainActor
final class ChangeTypeAccessoryViewModel {
    typealias TypeItem = HorizontalListItem

    @Published private(set) var isTypesViewVisible: Bool = false
    @Published private(set) var supportedTypes = [TypeItem]()
    var onDoneButtonTap: (() -> Void)?
    var onTypeSelected: ((TypeSelectionResult) -> Void)?

    let quickCapture: Bool

    private let router: any EditorRouterProtocol
    private let handler: any BlockActionHandlerProtocol
    private let document: any BaseDocumentProtocol

    @Injected(\.typesService)
    private var typesService: any TypesServiceProtocol

    private var cancellables = [AnyCancellable]()

    init(
        router: some EditorRouterProtocol,
        handler: some BlockActionHandlerProtocol,
        document: some BaseDocumentProtocol,
        quickCapture: Bool = false
    ) {
        self.router = router
        self.handler = handler
        self.document = document
        self.quickCapture = quickCapture
        self.isTypesViewVisible = quickCapture

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
        var types = try? await typesService
            .searchObjectTypes(
                text: "",
                includePins: true,
                // Sets and collections are containers, not capture targets
                includeLists: !quickCapture,
                includeBookmarks: true,
                includeFiles: false,
                includeChat: false,
                includeTemplates: false,
                incudeNotForCreation: false,
                spaceId: document.spaceId
            )
        if quickCapture {
            types = types?.sorted { ($0.lastUsedDate ?? .distantPast) > ($1.lastUsedDate ?? .distantPast) }
        }
        return types?.map { type in
            TypeItem(from: type, handler: { [weak self] in
                self?.onTypeSelected(result: .objectType(type: ObjectType(details: type)))
            })
        }
    }
}

extension ChangeTypeAccessoryViewModel: TypeListItemProvider {
    var typesPublisher: AnyPublisher<[HorizontalListItem], Never> {
        $supportedTypes.eraseToAnyPublisher()
    }
}
