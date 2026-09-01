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
    @Injected(\.quickCaptureTypeSuggestionService)
    private var suggestionService: any QuickCaptureTypeSuggestionServiceProtocol

    private var cancellables = [AnyCancellable]()
    private var lastFetchedTypes = [ObjectDetails]()
    private var suggestedTypeId: String?
    private var lastClassifiedText = ""
    private var suggestionTask: Task<Void, Never>?

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
        if quickCapture {
            subscribeOnContentForSuggestions()
        }
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
            settings: quickCapture ? .quickCaptureObjectCreation : .newObjectCreation,
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
        guard let types else { return nil }
        lastFetchedTypes = types
        return buildItems(from: types)
    }

    private func buildItems(from types: [ObjectDetails]) -> [TypeItem] {
        var ordered = types
        if let suggestedTypeId, let index = ordered.firstIndex(where: { $0.id == suggestedTypeId }) {
            let suggested = ordered.remove(at: index)
            ordered.insert(suggested, at: 0)
        }
        return ordered.map { type in
            TypeItem(
                from: type,
                isSuggested: type.id == suggestedTypeId,
                handler: { [weak self] in
                    self?.onTypeSelected(result: .objectType(type: ObjectType(details: type)))
                }
            )
        }
    }

    // MARK: - Quick capture type suggestions (on-device AFM)

    private func subscribeOnContentForSuggestions() {
        guard suggestionService.isAvailable else { return }
        document.syncPublisher
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.scheduleSuggestion()
            }
            .store(in: &cancellables)
    }

    // Keystrokes supersede a running classification - its answer describes text the
    // user already moved past. The debounce restarts it as soon as typing pauses,
    // so every pause still ends in a suggestion.
    private func scheduleSuggestion() {
        let text = draftText()
        guard text != lastClassifiedText else { return }
        suggestionTask?.cancel()
        suggestionTask = Task { [weak self] in
            guard let self else { return }
            let typeNames = lastFetchedTypes.map(\.name)
            // Types have not arrived yet - leave the text unclassified so it is retried
            guard typeNames.isNotEmpty else { return }
            let suggestion = await suggestionService.suggestType(text: text, typeNames: typeNames)
            guard !Task.isCancelled else { return }
            lastClassifiedText = text
            guard let suggestion, let type = lastFetchedTypes.first(where: { $0.name == suggestion }),
                  type.id != suggestedTypeId else { return }
            suggestedTypeId = type.id
            supportedTypes = buildItems(from: lastFetchedTypes)
        }
    }

    private func draftText() -> String {
        let title = document.details?.name ?? ""
        let body = document.children
            .compactMap { info -> String? in
                if case let .text(textContent) = info.content { return textContent.text }
                return nil
            }
            .joined(separator: "\n")
        return title + "\n" + body
    }
}

extension ChangeTypeAccessoryViewModel: TypeListItemProvider {
    var typesPublisher: AnyPublisher<[HorizontalListItem], Never> {
        $supportedTypes.eraseToAnyPublisher()
    }
}
