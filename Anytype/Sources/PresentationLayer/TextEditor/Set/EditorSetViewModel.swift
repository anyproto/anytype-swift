import Combine
import BlocksModels
import AnytypeCore
import ProtobufMessages
import SwiftUI

final class EditorSetViewModel: ObservableObject {
    @Published var titleString: String
    @Published var dataView = BlockDataview.empty
    @Published private var records: [ObjectDetails] = []
    @Published private(set) var headerModel: ObjectHeaderViewModel!
    @Published var loadingDocument = true
    @Published var pagitationData = EditorSetPaginationData.empty
    @Published var featuredRelations = [Relation]()
    @Published var configurations = [SetContentViewItemConfiguration]()
    
    @Published var sorts: [SetSort] = []
    @Published var filters: [SetFilter] = []

    var isUpdating = false
    
    var isEmpty: Bool {
        dataView.views.isEmpty
    }
    
    var activeView: DataviewView {
        dataView.views.first { $0.id == dataView.activeViewId } ?? .empty
    }
    
    var colums: [RelationMetadata] {
        sortedRelations.filter { $0.option.isVisible }.map(\.metadata)
    }
    
    var isSmallItemSize: Bool {
        activeView.cardSize == .small
    }
    
    var contentViewType: SetContentViewType {
        activeView.type.setContentViewType
    }
    
    var sortedRelations: [SetRelation] {
        dataBuilder.sortedRelations(dataview: dataView, view: activeView)
    }
 
    var details: ObjectDetails? {
        document.details
    }

    var relations: [RelationMetadata] {
        activeView.options.compactMap { option in
            let metadata = dataView.relations.first { relation in
                option.key == relation.key
            }
            
            guard let metadata = metadata,
                  shouldAddRelationMetadata(metadata) else { return nil }
            
            return metadata
        }
    }
    
    private var isObjectLocked: Bool {
        document.isLocked ||
        (FeatureFlags.setGalleryView && activeView.type == .gallery) ||
        (FeatureFlags.setListView && activeView.type == .list)
    }
    
    let document: BaseDocument
    private var router: EditorRouterProtocol!

    let paginationHelper = EditorSetPaginationHelper()
    private let subscriptionService = ServiceLocator.shared.subscriptionService()
    private let dataBuilder = SetContentViewDataBuilder()
    private let dataviewService: DataviewServiceProtocol
    private let searchService: SearchServiceProtocol
    private let detailsService: DetailsServiceProtocol
    private let textService: TextServiceProtocol
    private var subscriptions = [AnyCancellable]()
    private var titleSubscription: AnyCancellable?
    
    init(
        document: BaseDocument,
        dataviewService: DataviewServiceProtocol,
        searchService: SearchServiceProtocol,
        detailsService: DetailsServiceProtocol,
        textService: TextServiceProtocol
    ) {
        ObjectTypeProvider.shared.resetCache()
        self.document = document
        self.dataviewService = dataviewService
        self.searchService = searchService
        self.detailsService = detailsService
        self.textService = textService

        self.titleString = document.details?.pageCellTitle ?? ""
        self.featuredRelations = document.featuredRelationsForEditor
    }
    
    func setup(router: EditorRouterProtocol) {
        self.router = router
        self.headerModel = ObjectHeaderViewModel(document: document, router: router, isOpenedForPreview: false)
        
        document.updatePublisher.sink { [weak self] in
            self?.onDataChange($0)
        }.store(in: &subscriptions)

        Task { @MainActor in
            do {
                try await document.open()
                loadingDocument = false
                setupDataview()
            } catch {
                router.goBack()
            }
        }
    }
    
    func onAppear() {
        setupSubscriptions()
        router?.setNavigationViewHidden(false, animated: true)
    }
    
    func onWillDisappear() {
        router.dismissSetSettingsIfNeeded()
    }
    
    func onDisappear() {
        subscriptionService.stopAllSubscriptions()
    }

    func onRelationTap(relation: Relation) {
        AnytypeAnalytics.instance().logChangeRelationValue(type: .set)
        showRelationValueEditingView(key: relation.id, source: .object)
    }
    
    func updateActiveViewId(_ id: BlockId) {
        document.infoContainer.updateDataview(blockId: SetConstants.dataviewBlockId) { dataView in
            dataView.updated(activeViewId: id)
        }
        
        setupDataview()
    }
    
    func setupSubscriptions() {
        subscriptionService.stopAllSubscriptions()
        guard !isEmpty else { return }
        
        subscriptionService.startSubscription(
            data: .set(
                .init(
                    dataView: dataView,
                    view: activeView,
                    currentPage: max(pagitationData.selectedPage, 1) // show first page for empty request
                )
            )
        ) { [weak self] subId, update in
            guard let self = self else { return }

            if case let .pageCount(count) = update {
                self.updatePageCount(count)
                return
            }
            
            self.records.applySubscriptionUpdate(update)
            self.configurations = self.dataBuilder.itemData(
                self.records,
                dataView: self.dataView,
                activeView: self.activeView,
                colums: self.colums,
                isObjectLocked: self.isObjectLocked,
                onIconTap: { [weak self] details in
                    self?.updateDetailsIfNeeded(details)
                },
                onItemTap: { [weak self] details in
                    self?.itemTapped(details)
                }
            )
        }
    }
    
    // MARK: - Private
    
    private func onDataChange(_ data: DocumentUpdate) {
        switch data {
        case .general:
            objectWillChange.send()
            setupDataview()
        case .syncStatus, .blocks, .details, .dataSourceUpdate:
            objectWillChange.send()
            setupDataview()
        case .header:
            break // handled in ObjectHeaderViewModel
        }
    }
    
    private func setupDataview() {
        isUpdating = true

        anytypeAssert(document.dataviews.count < 2, "\(document.dataviews.count) dataviews in set", domain: .editorSet)
        document.dataviews.first.flatMap { dataView in
            anytypeAssert(dataView.views.isNotEmpty, "Empty views in dataview: \(dataView)", domain: .editorSet)
        }
        
        self.dataView = document.dataviews.first ?? .empty

        if let details = document.details {
            titleString = details.pageCellTitle

            titleSubscription = $titleString.sink { [weak self] newValue in
                guard let self = self, !self.isUpdating else { return }

                if newValue.contains(where: \.isNewline) {
                    self.isUpdating = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { // Return button tapped on keyboard. Waiting for iOS 15 support!!!
                        self.titleString = newValue.trimmingCharacters(in: .newlines)
                    }
                    UIApplication.shared.hideKeyboard()
                    return
                }

                self.textService.setText(
                    contextId: self.document.objectId,
                    blockId: BundledRelationKey.title.rawValue,
                    middlewareString: .init(text: newValue, marks: .init())
                )

                self.isUpdating = false
            }
        }

        updateActiveViewId()
        updateSorts()
        updateFilters()
        setupSubscriptions()
        featuredRelations = document.featuredRelationsForEditor

        isUpdating = false
    }
    
    private func updateActiveViewId() {
        let activeViewId = dataView.views.first(where: { $0.type.isSupported })?.id ?? dataView.views.first?.id
        if let activeViewId = activeViewId {
            if self.dataView.activeViewId.isEmpty || !dataView.views.contains(where: { $0.id == self.dataView.activeViewId }) {
                self.dataView.activeViewId = activeViewId
            }
        } else {
            dataView.activeViewId = ""
        }
    }
    
    private func updateSorts() {
        sorts = activeView.sorts.uniqued().compactMap { sort in
            let metadata = dataView.relations.first { relation in
                sort.relationKey == relation.key
            }
            guard let metadata = metadata else { return nil }
            
            return SetSort(metadata: metadata, sort: sort)
        }
    }
    
    private func updateFilters() {
        filters = activeView.filters.compactMap { filter in
            let metadata = dataView.relations.first { relation in
                filter.relationKey == relation.key
            }
            guard let metadata = metadata else { return nil }
            
            return SetFilter(metadata: metadata, filter: filter)
        }
    }
    
    private func shouldAddRelationMetadata(_ relationMetadata: RelationMetadata) -> Bool {
        guard sorts.first(where: { $0.metadata.key == relationMetadata.key }) == nil else {
            return false
        }
        guard relationMetadata.key != ExceptionalSetSort.name.rawValue,
              relationMetadata.key != ExceptionalSetSort.done.rawValue else {
            return true
        }
        return !relationMetadata.isHidden &&
        relationMetadata.format != .file &&
        relationMetadata.format != .unrecognized
    }
    
    private func isBookmarksSet() -> Bool {
        dataView.source.contains(ObjectTypeUrl.BundledTypeUrl.bookmark.rawValue)
    }
    
    private func isNotesSet() -> Bool {
        dataView.source.contains(ObjectTypeUrl.BundledTypeUrl.note.rawValue)
    }
    
    private func updateDetailsIfNeeded(_ details: ObjectDetails) {
        guard details.layoutValue == .todo else { return }
        detailsService.updateBundledDetails(
            contextID: details.id,
            bundledDpdates: [.done(!details.isDone)]
        )
    }
    
    private func itemTapped(_ details: ObjectDetails) {
        if !FeatureFlags.bookmarksFlow && isBookmarksSet(),
           let url = url(from: details) {
            router.openUrl(url)
        } else {
            openObject(pageId: details.id, type: details.editorViewType)
        }
    }
    
    private func url(from details: ObjectDetails) -> URL? {
        var urlString = details.values[EditorSetViewModel.urlRelationKey]?.stringValue ?? ""
        if !urlString.isEncoded {
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString
        }
        return URL(string: urlString)
    }
}

// MARK: - Routing
extension EditorSetViewModel {

    func showRelationValueEditingView(key: String, source: RelationSource) {
        if key == BundledRelationKey.setOf.rawValue {
            router.showTypesSearch(title: Loc.Set.SourceType.selectSource, selectedObjectId: document.details?.setOf.first) { [weak self] typeObjectId in
                self?.dataviewService.setSource(typeObjectId: typeObjectId)
            }

            return
        }

        AnytypeAnalytics.instance().logChangeRelationValue(type: .set)

        router.showRelationValueEditingView(key: key, source: source)
    }
    
    func showRelationValueEditingView(
        objectId: BlockId,
        source: RelationSource,
        relation: Relation
    ) {
        AnytypeAnalytics.instance().logChangeRelationValue(type: .set)
        
        router.showRelationValueEditingView(
            objectId: objectId,
            source: source,
            relation: relation
        )
    }
    
    func showViewPicker() {
        router.showViewPicker(setModel: self) { [weak self] activeView in
            guard let self = self else { return }
            self.router.showViewTypes(activeView: activeView, dataviewService: self.dataviewService)
        }
    }
    
    func showSetSettings() {
        router.showSetSettings(setModel: self)
    }

    func createObject() {
        if isBookmarksSet() {
            createBookmarkObject()
        } else {
            createDefaultObject()
        }
    }
    
    func showViewTypes() {
        router.showViewTypes(activeView: activeView, dataviewService: dataviewService)
    }
    
    func showViewSettings() {
        router.showViewSettings(
            setModel: self,
            dataviewService: dataviewService
        )
    }
    
    func showSorts() {
        router.showSorts(
            setModel: self,
            dataviewService: dataviewService
        )
    }
    
    func showFilters() {
        router.showFilters(
            setModel: self,
            dataviewService: dataviewService
        )
    }
    
    func showObjectSettings() {
        router.showSettings()
    }
    
    func showAddNewRelationView(onSelect: @escaping (RelationMetadata, _ isNew: Bool) -> Void) {
        router.showAddNewRelationView(onSelect: onSelect)
    }
    
    private func createDefaultObject() {
        let templateId: String
        if let objectType = dataView.source.first {
            let availableTemplates = searchService.searchTemplates(
                for: .dynamic(objectType)
            )
            let hasSingleTemplate = availableTemplates?.count == 1
            templateId = hasSingleTemplate ? (availableTemplates?.first?.id ?? "") : ""
        } else {
            templateId = ""
        }

        guard let objectDetails = dataviewService.addRecord(templateId: templateId, setFilters: filters) else { return }
        
        handleCreatedObjectDetails(objectDetails)
    }
    
    private func handleCreatedObjectDetails(_ objectDetails: ObjectDetails) {
        if isNotesSet() {
            openObject(pageId: objectDetails.id, type: objectDetails.editorViewType)
        } else {
            router.showCreateObject(pageId: objectDetails.id)
        }
    }
    
    private func openObject(pageId: BlockId, type: EditorViewType) {
        let screenData = EditorScreenData(pageId: pageId, type: type)
        router.showPage(data: screenData)
    }
    
    private func createBookmarkObject() {
        router.showCreateBookmarkObject()
    }
}

extension EditorSetViewModel {
    static let urlRelationKey = "url"
}

extension EditorSetViewModel {
    static let empty = EditorSetViewModel(
        document: BaseDocument(objectId: "objectId"),
        dataviewService: DataviewService(objectId: "objectId", prefilledFieldsBuilder: SetFilterPrefilledFieldsBuilder()),
        searchService: SearchService(),
        detailsService: DetailsService(objectId: "objectId", service: ObjectActionsService()),
        textService: TextService()
    )
}
