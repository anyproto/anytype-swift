import Combine
import BlocksModels
import AnytypeCore
import ProtobufMessages
import SwiftUI

final class EditorSetViewModel: ObservableObject {
    @Published var dataView = BlockDataview.empty
    @Published private var records: [ObjectDetails] = []
    @Published private(set) var headerModel: ObjectHeaderViewModel!
    
    @Published var pagitationData = EditorSetPaginationData.empty
    
    var isEmpty: Bool {
        dataView.views.filter { $0.isSupported }.isEmpty
    }
    
    var activeView: DataviewView {
        dataView.views.first { $0.id == dataView.activeViewId } ?? .empty
    }
    
    var colums: [RelationMetadata] {
        dataView.relationsMetadataForView(activeView)
            .filter { $0.isHidden == false }
    }
    
    var rows: [SetTableViewRowData] {
        records.map {
            let relations = relationsBuilder.parsedRelations(
                relationMetadatas: dataView.relationsMetadataForView(activeView),
                objectId: $0.id
            ).all
            
            let sortedRelations = colums.compactMap { colum in
                relations.first { $0.id == colum.key }
            }
            
            return SetTableViewRowData(
                id: $0.id,
                type: $0.editorViewType,
                title: $0.title,
                icon: $0.objectIconImage,
                allRelations: sortedRelations,
                colums: colums
            )
        }
    }
 
    var details: ObjectDetails {
        document.details ?? .empty
    }
    var featuredRelations: [Relation] {
        document.featuredRelationsForEditor()
    }
    
    let document: BaseDocument
    private(set) var router: EditorRouterProtocol!

    let paginationHelper = EditorSetPaginationHelper()
    private let relationsBuilder = RelationsBuilder(scope: [.object, .type])
    private var subscription: AnyCancellable?
    private let subscriptionService = ServiceLocator.shared.subscriptionService()
    
    init(document: BaseDocument) {
        self.document = document
    }
    
    func setup(router: EditorRouterProtocol) {
        self.router = router
        self.headerModel = ObjectHeaderViewModel(document: document, router: router)
        
        subscription = document.updatePublisher.sink { [weak self] in
            self?.onDataChange($0)
        }
        
        document.open()
        setupDataview()
    }
    
    func onAppear() {
        guard document.isOpened else {
            router.goBack()
            return
        }
        setupSubscriptions()
        router?.setNavigationViewHidden(false, animated: true)
    }
    
    func onDisappear() {
        subscriptionService.stopAllSubscriptions()
    }
    
    func showViewPicker() {
        router.presentFullscreen(
            AnytypePopup(viewModel: SetViewPickerViewModel(setModel: self))
        )
    }
    
    func showSetSettings() {
        router.presentFullscreen(
            AnytypePopup(
                viewModel: EditorSetSettingsViewModel(setModel: self),
                floatingPanelStyle: true
            )
        )
    }
    
    func showObjectSettings() {
        router.showSettings()
    }
    
    // MARK: - Private
    
    private func onDataChange(_ data: DocumentUpdate) {
        switch data {
        case .general:
            objectWillChange.send()
            setupDataview()
        case .syncStatus, .blocks, .details, .dataSourceUpdate:
            objectWillChange.send()
        case .header:
            break // handled in ObjectHeaderViewModel
        }
    }
    
    func setupDataview() {
        anytypeAssert(document.dataviews.count < 2, "\(document.dataviews.count) dataviews in set", domain: .editorSet)
        document.dataviews.first.flatMap { dataView in
            anytypeAssert(dataView.views.isNotEmpty, "Empty views in dataview: \(dataView)", domain: .editorSet)
        }
        
        self.dataView = document.dataviews.first ?? .empty
        
        updateActiveViewId()
        setupSubscriptions()
    }
    
    func updateActiveViewId(_ id: BlockId) {
        document.infoContainer.updateDataview(blockId: SetConstants.dataviewBlockId) { dataView in
            dataView.updated(activeViewId: id)
        }
        
        setupDataview()
    }
    
    private func updateActiveViewId() {
        if let activeViewId = dataView.views.first(where: { $0.isSupported })?.id {
            if self.dataView.activeViewId.isEmpty || !dataView.views.contains(where: { $0.id == self.dataView.activeViewId }) {
                self.dataView.activeViewId = activeViewId
            }
        } else {
            dataView.activeViewId = ""
        }
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
        }
    }
}
