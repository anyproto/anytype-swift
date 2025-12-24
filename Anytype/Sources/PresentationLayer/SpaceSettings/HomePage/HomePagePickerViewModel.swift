import Services
import Combine
import Foundation
import OrderedCollections
import AnytypeCore

@MainActor
final class HomePagePickerViewModel: ObservableObject {

    @Injected(\.searchWithMetaService)
    private var searchWithMetaService: any SearchWithMetaServiceProtocol
    @Injected(\.searchWithMetaModelBuilder)
    private var searchWithMetaModelBuilder: any SearchWithMetaModelBuilderProtocol
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol

    private let dateFormatter = AnytypeRelativeDateTimeFormatter()
    private let spaceId: String

    @Published var searchText = ""
    @Published var sections = [ListSectionData<String?, SearchWithMetaModel>]()
    @Published var selectedObjectId: String?
    @Published var dismiss = false

    private var searchResult = [SearchResultWithMeta]()
    var isInitial = true

    init(data: HomePagePickerModuleData) {
        self.spaceId = data.spaceId
        loadCurrentSelection()
    }

    func search() async {
        do {
            if needDelay() {
                try await Task.sleep(seconds: 0.3)
            }

            searchResult = try await searchWithMetaService.search(
                text: searchText,
                spaceId: spaceId,
                layouts: supportedLayouts(),
                sorts: buildSorts(),
                excludedObjectIds: []
            )

            updateInitialStateIfNeeded()
            updateSections()

        } catch is CancellationError {
            // Ignore cancellations
        } catch {
            sections = []
        }
    }

    func onWidgetsSelected() {
        userDefaults.clearLastOpenedScreen(spaceId: spaceId)
        selectedObjectId = nil
        dismiss.toggle()
    }

    func onObjectSelected(searchData: SearchWithMetaModel) {
        guard let details = searchResult.first(where: { $0.objectDetails.id == searchData.id })?.objectDetails else {
            return
        }

        let screen = buildLastOpenedScreen(from: details)
        userDefaults.setLastOpenedScreen(spaceId: spaceId, screen: screen)
        selectedObjectId = details.id
        dismiss.toggle()
    }

    private func loadCurrentSelection() {
        if let lastScreen = userDefaults.lastOpenedScreen(spaceId: spaceId) {
            switch lastScreen {
            case .editor(let data):
                selectedObjectId = data.objectId
            case .chat(let data):
                selectedObjectId = data.chatId
            case .spaceChat:
                selectedObjectId = nil
            }
        } else {
            selectedObjectId = nil
        }
    }

    private func buildLastOpenedScreen(from details: ObjectDetails) -> LastOpenedScreen {
        switch details.editorViewType {
        case .chat:
            if details.resolvedLayoutValue == .chatDerived {
                return .chat(ChatCoordinatorData(chatId: details.id, spaceId: details.spaceId))
            } else {
                return .chat(ChatCoordinatorData(chatId: details.chatId, spaceId: details.spaceId))
            }
        default:
            let editorData: EditorScreenData
            switch details.editorViewType {
            case .page:
                editorData = .page(EditorPageObject(details: details, mode: .handling, blockId: nil, usecase: .full))
            case .list:
                editorData = .list(EditorListObject(details: details, activeViewId: nil, mode: .handling, usecase: .full))
            case .date:
                editorData = .date(EditorDateObject(date: details.timestamp, spaceId: details.spaceId))
            case .type:
                editorData = .type(EditorTypeObject(objectId: details.id, spaceId: details.spaceId))
            default:
                editorData = .page(EditorPageObject(details: details, mode: .handling, blockId: nil, usecase: .full))
            }
            return .editor(editorData)
        }
    }

    private func updateSections() {
        guard searchResult.isNotEmpty else {
            sections = []
            return
        }

        let today = Date()
        let dict = OrderedDictionary(
            grouping: searchResult,
            by: { dateFormatter.localizedString(for: $0.objectDetails.lastModifiedDate ?? today, relativeTo: today) }
        )

        sections = dict.map { (key, result) in
            listSectionData(title: key, result: result)
        }
    }

    private func updateInitialStateIfNeeded() {
        guard isInitial else { return }
        isInitial = false
    }

    private func needDelay() -> Bool {
        !isInitial
    }

    private func listSectionData(title: String?, result: [SearchResultWithMeta]) -> ListSectionData<String?, SearchWithMetaModel> {
        ListSectionData(
            id: title ?? UUID().uuidString,
            data: title,
            rows: result.compactMap { result in
                searchWithMetaModelBuilder.buildModel(
                    with: result,
                    spaceId: spaceId,
                    participantCanEdit: false
                )
            }
        )
    }

    private func buildSorts() -> [DataviewSort] {
        .builder {
            SearchHelper.sort(
                relation: BundledPropertyKey.lastModifiedDate,
                type: .desc
            )
        }
    }

    private func supportedLayouts() -> [DetailsLayout] {
        // Include all visible layouts plus chats regardless of space type
        DetailsLayout.visibleLayoutsWithFiles(spaceUxType: .data)
    }
}
