import UIKit
import Combine
import Services
import AnytypeCore

final class ChangeTypeAccessoryViewModel {
    typealias TypeItem = HorizontalListItem

    @Published private(set) var isTypesViewVisible: Bool = false
    @Published private(set) var supportedTypes = [TypeItem]()
    var onDoneButtonTap: (() -> Void)?
    var onTypeTap: ((TypeSelectionResult) -> Void)?

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
        router.showTypePickerForNewObjectCreation(
            selectedObjectId: document.details?.type,
            onSelect: { [weak self] result in
                self?.onTypeTap(result: result)
            }
        )
    }

    private func onTypeTap(result: TypeSelectionResult) {
        defer { logSelectObjectType(result: result) }
        onTypeTap?(result)
    }
    
    private func logSelectObjectType(result: TypeSelectionResult) {
        switch result {
        case .object(let type, let pasteContent):
            AnytypeAnalytics.instance().logSelectObjectType(type.analyticsType, route: .navigation)
        case .bookmark(let url):
            if let type = try? ObjectTypeProvider.shared.objectType(uniqueKey: .bookmark, spaceId: document.spaceId) {
                AnytypeAnalytics.instance().logSelectObjectType(type.analyticsType, route: .navigation)
            }
        }
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
                spaceId: document.spaceId
            ).map { type in
                TypeItem(from: type, handler: { [weak self] in
                    self?.onTypeTap(result: .object(type: ObjectType(details: type), pasteContent: false))
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
