import Combine
import BlocksModels
import AnytypeCore
import ProtobufMessages
import SwiftUI

final class EditorSetViewModel: ObservableObject {
    @Published var dataView = BlockDataview.empty
    @Published var activeViewId: BlockId = "" {
        didSet {
            setupSubscriptions()
        }
    }
    @Published private var records: [ObjectDetails] = []
    
    @Published var showViewPicker = false
    
    var activeView: DataviewView {
        dataView.views.first { $0.id == activeViewId } ?? .empty
    }
    
    var colums: [SetColumData] {
        dataView.relationsMetadataForView(activeView)
            .filter { $0.isHidden == false }
            .map { SetColumData(key: $0.key, value: $0.name) }
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
//                allMetadata: [], // todo: Use metadata from rows data
                colums: colums
            )
        }
    }
 
    var details: ObjectDetails {
        document.objectDetails ?? .empty
    }
    var featuredRelations: [Relation] {
        document.parsedRelations.featuredRelationsForEditor(type: details.objectType)
    }
    
    let document: BaseDocument
    var router: EditorRouterProtocol!
    
    private let relationsBuilder = RelationsBuilder(scope: .type)
    private var subscription: AnyCancellable?
    private let subscriptionService = ServiceLocator.shared.subscriptionService()
    
    init(document: BaseDocument) {
        self.document = document
        setup()
    }
    
    func onAppear() {
        setupSubscriptions()
    }
    
    func onDisappear() {
        subscriptionService.stopAllSubscriptions()
    }
    
    // MARK: - Private
    private func setup() {
        subscription = document.updatePublisher.sink { [weak self] in
            self?.onDataChange($0)
        }
        
        if !document.open() { router.goBack() }
        if !setupDataview() { router.goBack() }
    }
    
    private func onDataChange(_ data: EventsListenerUpdate) {
        switch data {
        case .general, .syncStatus, .blocks, .details:
            objectWillChange.send()
        case .dataview(let data):
            update(data)
        }
    }
    
    private func setupDataview() -> Bool {
        let dataViews = document.flattenBlocks.compactMap { block -> BlockDataview? in
            if case .dataView(let data) = block.information.content {
                return data
            }
            return nil
        }
        
        anytypeAssert(dataViews.count == 1, "\(dataViews.count) dataviews instead of 1 in set", domain: .editorSet)
        guard let dataView = dataViews.first else { return false }
        anytypeAssert(dataView.views.isNotEmpty, "Empty views in dataview: \(dataView)", domain: .editorSet)
        guard let activeView = dataView.views.first(where: { $0.isSupported }) else { return false }
        
        self.dataView = dataView
        self.activeViewId = activeView.id

        return true
    }
    
    private func setupSubscriptions() {
        subscriptionService.stopAllSubscriptions()
        subscriptionService.startSubscription(
            data: .set(
                source: dataView.source,
                sorts: activeView.sorts,
                filters: activeView.filters,
                relations: activeView.relations
            )
        ) { [weak self] subId, update in
            self?.records.applySubscriptionUpdate(update)
        }
    }
}
